0. Set static ip address for the host machine

1. Create docker network:
    ```
    docker network create --subnet=10.0.0.0/24 --gateway=10.0.0.1 dockitt_network
    ```

2. Edit dnsmasq/dnsmasq.conf to set the server ip that you changed at step 0
3. Run dnsmasq

4. Run Nginx Proxy Manager
5. Open `http://localhost:81` and create admin account

6. Run it-tools
7. Configure NPM proxy for it-tools

8. Run Gitea
9. Configure NPM proxy for Gitea
10. Open `http://git.dockitt.local/` and create admin account
11. Generate OAuth2 on Gitea for Drone
12. Copy ClienID and ClientSecret to Drone docker-compose.yml

13. Run Drone
14. Configure NPM proxy for Drone
15. Open `http://drone.dockitt.local/`, then authorize for Drone on Gitea (auto open Gitea page)
16. Register on Drone

17. Run BookStack
18. Configure NPM proxy for BookStack
19. Open `http://docs.dockitt.local/`

20. Run Adminer
21. Configure NPM proxy for Adminer
22. Open `http://db.dockitt.local/`

23. Run Uptime-Kuma
24. Configure NPM proxy for Uptime-Kuma
25. Open `http://status.dockitt.local/`


