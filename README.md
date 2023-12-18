Commands to complete the setup:

Enter MySQL Shell:
```
mysql
````
Create DB:
```
CREATE DATABASE wordpress;
```
Create DB User
```
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY '<enter password here>';
```
Grant privileges:
```
GRANT ALL PRIVILEGES ON wordpress.* to 'wp_user'@'localhost';
```
Flush privileges:
```
FLUSH PRIVILEGES;
```

Edit 'wp-config-sample.php' with DB_NAME, DB_USER and DB_PASSWORD.

Rename sample config
```
cp -a wp-config-sample.php wp-config.php
```


