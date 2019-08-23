# Atlassian Confluence in a Docker container
This is a containerized installation of Atlassian Confluence with Docker, and it's a match made in heaven for us all to enjoy. The aim of this image is to keep the installation as straight forward as possible, but with a few Docker related twists. You can get started by clicking the appropriate link below and reading the documentation.

*  [Atlassian Confluence](https://cptactionhank.github.io/docker-atlassian-confluence)

## Supported Tags And Respective Dockerfile Links
| Product | Version | Tags | Dockerfile |
| ------ | ------ | ------ | ------ |
| Confluence | 6.15.7 | 6.15.7 | latest |
| MySQL | 5.1.42 | 5.1.42 | latest |


## Setup

1.  Proxy Configuration
2.  Start the database container
2.  Start Confluence
3.  Setup Confluence

### Proxy Configuration
You can specify your proxy host and proxy port with the environment variables *PROXY_NAME* and *PROXY_PORT*. The value will be set inside the Atlassian server.xml at startup!

When you use https then you also have to include the environment variable *PROXY_SCHEME*.

Example HTTPS:

*  Proxy Name: myhost.example.com
*  Proxy Port: 443
*  Poxy Protocol Scheme: https

### MySQL

On [DB On Demand](https://resources.web.cern.ch/resources/Manage/DbOnDemand/Resources.aspx) you can ask for a DB for your apps.

[Administration Panel](https://dbod.web.cern.ch)

Now start the Confluence container and let it use the container. On first startup you have to configure your Confluence yourself and fill it with a test license.

1.  Choose Production Installation because we have a mysql!
2.  Enter license information
3.  In Choose a Database Configuration choose MySQL and press External Database
4.  In Configure Database press Direct JDBC
5.  In Configure Database fill out the form:
6.  Driver Class Name: com.mysql.jdbc.Driver
7.  Database URL: jdbc:mysql://mysql/confluencedb?sessionVariables=storage_engine%3DInnoDB&useUnicode=true&characterEncoding=utf8
8.  User Name: USER_NAME
9.  Password: USER_PASSWORD