## Speed Test

Performs a simple speedtest and records the results in a database, which can be tracked and analysed.  Put it in your scheduler (eg, cron) and run at a regular frequency (eg, every hour).

### IP Tracking

During each speed test, your external IP is recorded.  If your IP changes (eg, if you have a dynamic IP that gets updated), a notification will be emailed to you.

I have a domain name point to my home server.  Unfortunately, my IP address is dynamic so it changes from time to time.  Fortunately, it usually stays static for several months at a time.  So as long as I get a warning that the IP address has changed, it doesn't take much effort to re-point my domain to the new IP address.  Since I run the speed test every hour, it makes sense to also use it to track whether my IP has changed.

