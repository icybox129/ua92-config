# Installing WordPress on AWS - automated using Terraform and a Bash script

This Terraform configuration will create an Ubuntu EC2 AWS instance, with all the underlying network infrastructure (vpc, subnet, internet gateway, route table and security groups). It will also create an A record for a subdomain, using the EC2 instances' public IP address.

The Bash script will; 
 - Install all neccessary apps (including PHP, NGINX and MySQL)
 - Use certbot to enable HTTPS certificates
 - Download and configure WordPress
 - Automatically add WordPress SALT keys to the wordpress config file

 (A more detailed explanation of the bash script will be at the bottom of this README)

There will be some manual commands to complete the installation, you will find these further down

---

## Setup

If you wish to use this Terraform config and Bash script yourself, there are a few prerequisites;

- You will need Terraform installed and ideally a AWS profile setup (using the AWS CLI). 

    - If you do not have a AWS profile setup with your AWS credentials, then in the 'variables.tf' file located in the '/environment/dev' folder, uncomment lines 1 and 3 and Terraform will prompt you for your credentials with you apply the configuration.
- You will need your domain (Hosted zone) added to AWS Route 53
    - Once your hosted zone is created, you will need to update the 'r53.tf' file in 'modules/r53'. On line 2, change the 'zone_id' string to your hosted zone ID.
    - While still in the 'r53.tf' file, on line 7, change the string with your desired subdomain (for example my domain is icybox.co.uk and I am creating an A record for the subdomain wp.icybox.co.uk)
- Update the two .conf files, including;
    - Renaming the files to your domain
    - Updating lines 2, 3 and 11 in the NGINX config file to the relevant values for you
    - Updating lines 1, 2, 3, 4 and 14 in the PHP config file to the relevant values for you
- Edit the 'user-data.sh' file in the '/modules/network/' directory. Specifically lines 7, 20, 21, 26, 31, 35, 36, 42 and 43. The main edits will be changing the username from 'nick' to whatever you choose and the source of your config files for nginx and php.

---

## Terraform Commands

Make sure you're in the '/environment/dev' directory and initialise the Terraform configuration
```
terraform init
```
Validate the configuration to make sure there are no errors
```
terraform validate
```

Apply the configuration to begin provisioning the infrastructure on AWS
<br> (you will be prompted to confirm by typing 'yes' into the command line)
```
terraform apply
```

---

## Commands to complete the setup:

Enter MySQL Shell:
```
mysql
````
Create DB:
```
CREATE DATABASE wordpress;
```
Create DB User
<br>(replaced <enter password here> with your desired password)
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

---

## Bash Script

Below you will find some snippets of the Bash script with an explanation of what they do (initially I was going to comment the script itself, but it looked a bit messy)

You can find the whole script located in the '/modules/network' directory, in the 'user-data.sh' file.

---

After you do a 'apt update' and 'apt upgrade' you will get a interactive popup telling you about a pending kernel upgrade and that you should reboot and another about restarting services. The following two lines will edit a config file to disable the interactive window from appearing, allowing the script to continue.

Note that you will still need to restart your instance for the kernel upgrades to take affect
```
sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
```

I wanted to highlight the below installation of PHP. When you install PHP it will also install Apache2 as part of it and start the service will start automatically, conflicting with NGINX. However, if you install 'php-fpm' before 'php', Apache2 will still be installed, but the service won't start.
```
apt install php-fpm php php-mysql php-curl php-gd php-imagick php-mbstring php-xml php-xmlrpc -y
```

When you run the 'mysql_secure_installation' command, it requires some Y/N inputs to complete. The <<EOF command allows you add in the inputs you need and continue with the bash script afterwards

```
mysql_secure_installation <<EOF
n
y
y
y
y
EOF
```

Here I am using 'wget' to download the RAW versions of the config files, using the -P flag to download them to a specific directory.

```
wget -P /etc/php/8.1/fpm/pool.d/ https://raw.githubusercontent.com/icybox129/ua92-config/main/wp_icybox_co_uk.conf
wget -P /etc/nginx/conf.d/ https://raw.githubusercontent.com/icybox129/ua92-config/main/wp.icybox.co.uk.conf
```

This command is using certbot to enable HTTPS on the 'wp.icybox.co.uk' subdomain. The --nginx flag is automatically going to update my existing NGINX config to work with HTTPS requests. I am again using the <<EOF command to allow the script to complete the user input steps.

```
certbot --nginx -d wp.icybox.co.uk <<EOF
test@test.com
y 
n
EOF
```

Essentially the following snippet grabs the SALT keys from the URL and replaces the relevant lines in the 'wp-config-sample.php' file.

```
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s wp-config-sample.php
```