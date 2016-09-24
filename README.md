# Kraken - Web Interface Survey Tool
Kraken is a tool to help make your web interface testing workflow more efficient. This is done by using Django and a MySql database to store and organize web interface screenshots and data. This allows you and your team to take notes and track which hosts have been tested at the same time. Once you are finished, you can view these systems and the notes you took in the Reports section. 

## Installation

Clone the repository down and run the following commands:

```# chmod 755 setup.sh```

```# ./setup.sh```

You will be asked to supply a TCP port to host Kraken on. The default port is 8000. The setup script will ensure that your system is not using the port selected before proceeding.

Once setup is complete, open your browser and visit http://localhost:<port> and use the following default credentials to log in:

admin:2wsxXSW@

Password change and add user functionality can be found at http://localhost:8000/admin

## Usage

Kraken drops a script in /usr/bin so that you can stop, start, reset, and update Kraken. 

To get started, make your way over to Web Scout's Setup page. Web Scout is what you will use to scan, and review, the web interfaces accessible on a given network. Kraken will parse port data from an Nmap XML file. The parser will look for either 'HTTP' to be present in the port entry, or one of the following known HTTP ports:

```
80,280,443,591,593,981,1311,2031,2480,3181,4444,4445,4567,4711,4712,5104,5280,7000,7001,7002,8000,8008,8011,8012,8013,8014,8042,8069,8080,8081,8243,8280,8281,8443,8531,8887,8888,9080,9443,11371,12443,16080,18091,18092
```

Web Scout's Setup page provides your with file upload functionality to provide your Nmap XML file. Behind the scenes, a Celery task will parse the Nmap XML data into the SQLite database. The last step for setup is to click the "Take Screenshots" button. Celery workers will screenshots all interfaces in the database. The progress field will display a completion percentage and will show 'SUCCESS' when complete. This may take a while depending on how many screenshots need to be taken. The screenshot-taking Celery task currently uses 5 workers, each with a Selenium headless PhantomJS web driver, so it can be fairly resource intensive. During the screenshot taking process, interfaces are identified by type if possible, and any known default credentials are displayed in the 'viewer.html' page.

Once all of your screenshots are taken, visit Web Scout's main page to see the listing of your web interfaces. Each host gets a Bootstrap 'well'. Each web interace hosted by that host is grouped into that well along with IP, hostname, and basic port information. Clicking a screenshot thumbnail will popup a larger image along with more detailed information about that interface and host. Within this popup you can take notes, check the check boxes for HTTP Authentication and Default Credentials, and mark the host as reviewed. Hit save to record those notes in the database. All of your notes can be reviewed in Reports. Clicking "KrakenView" will open another tab where that will attempt to load that interface into an iframe with a Kraken toolbar at the top. The toolbar allows you to take the same notes you can with the popup and provides you with any known default credentials. There is also a link in case the page is not able to load in the iframe.

You can cycle through the interfaces on each page using the popup by either clicking the Next/Previous buttons or hitting the right/left arrows on your keyboard. The workflow Kraken was designed for is to go through a couple of Web Scout pages using the popup and open web interfaces with KrakenView in the background as you go (Ctrl + left-click for Windows or Option + left-click for Mac). Afterwards, go through the tabs and take notes as I go. 

## Troubleshooting

If you run into other issues, try executing the following command before performing further troubleshooting:

```# Kraken start```

Django's debugging has been left on to assist in further troubleshooting. 
