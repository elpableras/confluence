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

### Configure MySQL Server

* Before you start 

1.  Edit the my.cnf file

Specify the default character set to be UTF-8:

```
[mysqld]
...
character-set-server=utf8
collation-server=utf8_bin
...
```

*  Set the default storage engine to InnoDB:

```
[mysqld]
...
default-storage-engine=INNODB
...
```

* Specify the value of max_allowed_packet to be at least 256M:

```
[mysqld]
...
max_allowed_packet=256M
...
```

*  Specify the value of innodb_log_file_size to be at least 2GB:

```
[mysqld]
...
innodb_log_file_size=2GB
...
```

* Ensure the sql_mode parameter does not specify NO_AUTO_VALUE_ON_ZERO

```
// remove this if it exists
sql_mode = NO_AUTO_VALUE_ON_ZERO
```

* Ensure that the global transaction isolation level of your Database had been set to READ-COMMITTED.

```
[mysqld]
...
transaction-isolation=READ-COMMITTED
...
```

* Check that the binary logging format is configured to use 'row-based' binary logging.

```
[mysqld]
...
binlog_format=row
...
```


2. Create database and database user

Once you've installed and configured MySQL, create a database user and database for Confluence as follows:


    1. Run the 'mysql' command as a MySQL super user. The default user is 'root' with a blank password.
    2. Create an empty Confluence database schema (for example confluence):

        `CREATE DATABASE <database-name> CHARACTER SET utf8 COLLATE utf8_bin;`


    3. Create a Confluence database user (for example confluenceuser): 

        `GRANT ALL PRIVILEGES ON <database-name>.* TO '<confluenceuser>'@'localhost' IDENTIFIED BY '<password>';`

If Confluence is not running on the same server, replace localhost with the hostname or IP address of the Confluence server. 



Now start the Confluence container and let it use the container. On first startup you have to configure your Confluence yourself and fill it with a test license.

1.  Choose Production Installation because we have a mysql!
2.  Enter license information
3.  In Choose a Database Configuration choose MySQL and press External Database
4.  Simple - this is the most straightforward way to connect to your database.
5.  In Configure Database fill out the form:
    6.  Hostname. This is the hostname or IP address of your database server.  
    7.  Port. This is the MySQL port. If you didn't change the port when you installed MySQL, it will default to 3306.
    8.  Database name. This is the name of your confluence database. In the example above, this is confluence
    9.  Username. This is the username of your dedicated database user. In the example above, this is confluenceuser.
    10.	Password. This is the password for your dedicated database user.
11.	Test your database connection