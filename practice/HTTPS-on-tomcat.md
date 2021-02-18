## 为 tomcat 应用 Let’s Encrypt 证书

Let’s Encrypt 是一个证书颁发机构（CA），用于为网站颁发 SSL/TLS 证书，免费、开放、自动化是其特点。

 > 传输层安全性协议（英语：Transport Layer Security，缩写：TLS）及其前身安全套接层（英语：Secure Sockets Layer，缩写：SSL）是一种安全协议，目的是为互联网通信提供安全及数据完整性保障。-- 摘自 wiki。

这篇文章记录在 tomcat 8 中应用 Let’s Encrypt 证书的过程。

### 1. 前提

 - 有一个服务器并配有公网 IP 地址，一个域名并解析至此 IP。
 - 80 和 443 端口已对外暴露。
 - root 或 sudo root 权限。
 - Java 8 以上。
 - tomcat 8 以上可使用 80 提供 HTTP 服务，使用 443 端口提供 HTTPS 服务。

### 2. 安装 Certbot

参看 [Get Certbot](https://certbot.eff.org/docs/install.html)，certbot 有多种安装方式。此处示例为 CentOS 7 系统上的安装方式。

#### 2.1 yum 安装

CentOS 7 可以通过：

    # yum install epel-release
    # yum install certbot

安装的 certbot 版本是 1.9.0-1，安装过程会出现类似错误，但是 certbot 可以安装成功：

    Error unpacking rpm package python2-urllib3-1.16-1.el7.noarch
    error: unpacking of archive failed on file /usr/lib/python2.7/site-packages/urllib3/packages/ssl_match_hostname: cpio: rename
      Verifying  : python2-urllib3-1.16-1.el7.noarch

    Failed:
      python2-urllib3.noarch 0:1.16-1.el7

执行时会有如下出错信息：

    pkg_resources.DistributionNotFound: The 'urllib3!=1.25.0,!=1.25.1,<1.26,>=1.21.1' distribution was not found and is required by requests

按照这个提示卸载不合适的 urllib3 把本，然后重新安装特定版本：

    # pip install urlib3==1.25.11

然后遇到：

    ImportError: 'pyOpenSSL' module missing required functionality. Try upgrading to v0.14 or newer.

参考 [https://github.com/certbot/certbot/issues/5534](https://github.com/certbot/certbot/issues/5534) 通过升级 requests 解决：

    pip install --upgrade --force-reinstall 'requests==2.6.0'

完成以上两个步骤后可正常使用 `certbot` 命令。

#### 2.2 脚本安装

比较新的版本可以通过 `certbot-auto` 脚本进行安装。

    # wget https://dl.eff.org/certbot-auto
    # chmod a+x certbot-auto
    # ./certbot-auto

 > 卡在 `Installing Python packages...` 很久，参考 [https://github.com/certbot/certbot/issues/2516](https://github.com/certbot/certbot/issues/2516) 解决。

### 3. 生成泛域名证书

生成泛域名证书，这样证书可以应用于所有子域名，以主域名 dunnen.top 为例，则命令可以是：

    # certbot certonly --preferred-challenges dns --manual -d dunnen.top -d *.dunnen.top --email zhegema@126.com

 > 如果配置了直接解析主域名，则需要把主域名也声明在命令中，即 `-d dunnen.top`。

`--preferred-challenges dns` 表示通过 DNS 方式验证域名是否有效，执行后会出现如下信息：

    Please deploy a DNS TXT record under the name
    _acme-challenge.dunnen.top with the following value:

    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    Before continuing, verify the record is deployed.
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Press Enter to Continue

按照这个提示，在继续操作前，需要先在域名解析里添加一条 TXT 记录。添加后，通过 dig 命令来验证 `_acme-challenge.dunnen.top` 的解析是否已生效：

    dig -t txt _acme-challenge.dunnen.top @8.8.8.8

确定生效后，再 **Enter** 来继续证书的生成过程。成功生成后，会出现如下提示信息：

    IMPORTANT NOTES:
     - Congratulations! Your certificate and chain have been saved at:
       /etc/letsencrypt/live/dunnen.top/fullchain.pem
       Your key file has been saved at:
       /etc/letsencrypt/live/dunnen.top/privkey.pem
       Your cert will expire on 2021-02-20. To obtain a new or tweaked
       version of this certificate in the future, simply run certbot
       again. To non-interactively renew *all* of your certificates, run
       "certbot renew"
     - If you like Certbot, please consider supporting our work by:

       Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
       Donating to EFF:                    https://eff.org/donate-le

证书有效期为 3 个月，到期前 1 个月内可重新生成新的证书，或通过 `certbot renew` 自动续期。

### 4. 在 tomcat 中配置证书

参看 [Apache Tomcat&reg; - Which Version Do I Want?](https://tomcat.apache.org/whichversion.html)，这里选用最新的 8.5.x 版本。8.5.x 版本的 tomcat 支持 OpenSSL 风格的证书配置，优势在于无需先生成 JSSE 风格需要的 keystore 证书文件。参考 `conf/server.xml` 中的提示，配置如下：

    <Connector port="443" protocol="org.apache.coyote.http11.Http11NioProtocol"
               maxThreads="150" SSLEnabled="true">
        <SSLHostConfig>
            <Certificate certificateKeyFile="/etc/letsencrypt/live/dunnen.top/privkey.pem"
                         certificateFile="/etc/letsencrypt/live/dunnen.top/cert.pem"
                         certificateChainFile="/etc/letsencrypt/live/dunnen.top/chain.pem"
                         type="RSA" />
        </SSLHostConfig>
    </Connector>

 > `conf/server.xml` 提示：如果需要升级成 HTTP/2 协议，需要 APR/native 支持。且安装 APR/native 后 tomcat 将会有更好的性能。会另写一篇文章来进行实践。
 >
 > 参见：[Apache Tomcat Native Library - Documentation Index](https://tomcat.apache.org/native-doc/)

重启 tomcat，在 `catalina.out` 日志中可以看到如下输出：

    INFO [main] org.apache.coyote.AbstractProtocol.start Starting ProtocolHandler ["http-nio-80"]
    INFO [main] org.apache.coyote.AbstractProtocol.start Starting ProtocolHandler ["https-jsse-nio-443"]
    INFO [main] org.apache.catalina.startup.Catalina.start Server startup in 6417 ms

表示启动成功，然后便可浏览器中通过 [https://dunnen.top](https://dunnen.top) 访问网站。

但是还有个问题：在未做任何配置的情况下，默认仍然可以通过不安全的 http 方式访问网站，即同时支持 http://dunnen.top 和 https://dunnen.top 两种访问方式。在 `conf/web.xml` 中配置所有的 HTTP 请求重定向到 HTTPS，才可改变这个默认行为，配置方式如下：

    <web-app>

        ... pre omitted ...

        <!-- new added for redirecting http to https -->
        <security-constraint>
            <web-resource-collection>
                <web-resource-name>Secured</web-resource-name>
                <url-pattern>/*</url-pattern>
            </web-resource-collection>
            <user-data-constraint>
                <transport-guarantee>CONFIDENTIAL</transport-guarantee>
            </user-data-constraint>
        </security-constraint>

        ... post omitted ...

    </web-app>

### 5. 撤销一个证书

通过 `certbot certificates` 可以查看服务器上已获取的证书：

    # certbot certificates

输出如下信息：

    Saving debug log to /var/log/letsencrypt/letsencrypt.log
    OCSP check failed for /etc/letsencrypt/live/dunnen.top/cert.pem (are we offline?)

    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    Found the following certs:
      Certificate Name: dunnen.top
        Serial Number: 4d5e4ee28c14757b1fa402c88e73cbb38ca
        Domains: *.dunnen.top
        Expiry Date: 2021-02-20 02:05:39+00:00 (VALID: 89 days)
        Certificate Path: /etc/letsencrypt/live/dunnen.top/fullchain.pem
        Private Key Path: /etc/letsencrypt/live/dunnen.top/privkey.pem
    - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

通过提供 `--cert-name` 删除证书，如：

    # certbot revoke --cert-name dunnen.top

删除后，`/etc/letsencrypt/live/` 下的 `--cert-name` 目录和其下证书文件将会被删除，表示撤销成功。

### 6. 更新证书

通过 `--manul` 申请的证书无法通过 `certbot renew` 来直接更新，需要参照第 3 节中的过程重新生成一遍，讨论见：[--manual should display a warning about the inability to use certbot renew](https://github.com/certbot/certbot/issues/6280)。

### 7. 总结

 1. yum 安装的 certbot 1.9.0 版本需要通过两步修正，才可以正常使用 `certbot` 命令。也许随着 epel 中 certbot 的版本更新，会带来更好的兼容性，期待中。
 2. OpenSSL 风格的证书配置相比于 JSSE 更加通用，因为其他一些 web 服务器软件，比如 nginx，也是直接基于证书进行配置的。而且更加简单，无需额外的步骤生成 keystore 文件。这也是选用 tomcat 8.5 以上版本的主要原因。
 3. 总体来说，这个操作过程没有什么难度。但是要理解各项操作对应的规范、原理就比较困难了。

--------

**参考：**

 - [Get Certbot](https://certbot.eff.org/docs/install.html)
 - [Apache Tomcat 8 - SSL/TLS Configuration How-To](https://tomcat.apache.org/tomcat-8.5-doc/ssl-howto.html)
 - [How to use the certificate for Tomcat - Server](https://community.letsencrypt.org/t/how-to-use-the-certificate-for-tomcat/3677)
 - [--manual should display a warning about the inability to use certbot renew](https://github.com/certbot/certbot/issues/6280)

