# Mikrotik Duck DNS Dynamic IP Updater
## How to use
#### 1.  Duck DNS token and subdomain
Go to [duckdns.org](https://www.duckdns.org) authorise and get your token.  
![](https://raw.githubusercontent.com/beeyev/Mikrotik-Duckdns-Dynamic-IP-Updater/master/howto/get-token.png)

Then create your new subdomain.  
![](https://raw.githubusercontent.com/beeyev/Mikrotik-Duckdns-Dynamic-IP-Updater/master/howto/make-subdomain.png)

#### 2. Create new mikrotik script
Using WinBox tool, go to: System -> Scripts [Add]  
  
**Imprtant!** Script name has to be `Duckdns-Dynamic-IP-Updater`  
Put [script source](https://raw.githubusercontent.com/beeyev/Mikrotik-Duckdns-Dynamic-IP-Updater/master/mikrotik-duckdns-dynamic-ip-updater.rsc) and set your **token** and **subdomain** into corresponding variables.
![](https://raw.githubusercontent.com/beeyev/Mikrotik-Duckdns-Dynamic-IP-Updater/master/howto/script-name-params.png)

> If you want to use **IPv6**, change `ipv6mode` variable in the script  

#### 3. Create scheduled task
WinBox: System -> Scheduler [Add]  
  
Name: `Duckdns-Dynamic-IP-Updater`  
Start Time: `00:10:00`  
Interval: `01:10:00`  
On Event: `/system script run Duckdns-Dynamic-IP-Updater;`  
Scheduler will run the script to update IP address every hour. If you want to make it more frequently, change the "Interval" parameter.

![](https://raw.githubusercontent.com/beeyev/Mikrotik-Duckdns-Dynamic-IP-Updater/master/howto/scheduler-task.png)

Or you can use this command to create the task:
```
/system scheduler add name="Duckdns-Dynamic-IP-Updater" on-event="/system script run Duckdns-Dynamic-IP-Updater;" start-time=00:10:00 interval=01:10:00 comment="" disabled=no
```
---
If you love this project, please consider giving me a ⭐
