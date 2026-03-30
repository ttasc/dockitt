### Services
- [x] Source Control & CI/CD: [Gitea](https://about.gitea.com/), [Drone CI](https://www.drone.io/)
- [x] Knowledge-Base/Wiki: [BookStack](https://www.bookstackapp.com/)
- [x] Monitoring & Observability: [Uptime Kuma](https://uptimekuma.org/)
- [x] Database Tools: [Adminer](https://www.adminer.org/en/)
- [x] Dev Tools: [IT Tools](https://it-tools.tech/)
- [x] Network Management: [dnsmasq](https://github.com/howtomgr/dnsmasq), [Nginx Reverse Proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)
- [ ] Project Management (suggest): [Plane](https://plane.so/)
- [ ] Communication (suggest): [Mattermost](https://mattermost.com/)

### Auto Setup

1. Clone the repository: `git clone https://github.com/ttasc/dockitt.git`
2. Move to the cloned directory: `cd dockitt`
3. Run `./setup.sh`
4. Then follow the instructions.

### Manual Setup

0. Set static ip address for the host machine

1. Create docker network:
    ```
    docker network create --subnet=10.0.0.0/24 --gateway=10.0.0.1 dockitt_network
    ```

> To run a service: go inside the service folder and run `docker-compose up -d`

2. Edit dnsmasq/dnsmasq.conf to set the server ip that you changed at step 0
    > For example, edit line 21: `address=/.dockitt.local/192.168.28.47`
3. Run dnsmasq

4. Run Nginx Proxy Manager
5. Open `http://localhost:81` and create admin account

    > To Configure NPM proxy for the services, do the following:
    >
    > Example with IT-Tools:
    >
    > - Go to the Hosts tab -> Select Proxy Hosts -> Click Add Proxy Host.
    >
    > - Fill in the following information:
    >
    >   - Domain Names: `tools.dockit.local`
    >
    >   - Scheme: `http`
    >
    >   - Forward Hostname/IP: `it-tools` (This is the container_name you declared in *Step 3*)
    >
    >   - Forward Port: 80 (The default port of IT-Tools inside the container)
    >
    > - Check the box for **Block Common Exploits**.
    >
    > - Click **Save**.

6. Run it-tools
7. Configure NPM proxy for it-tools

8. Run Gitea
9. Configure NPM proxy for Gitea
10. Open `http://git.dockitt.local/` and create admin account

11. Run Drone
12. Configure NPM proxy for Drone
13. Generate OAuth2 on Gitea for Drone
14. Copy ClienID and ClientSecret to Drone docker-compose.yml
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

26. All computers wishing to access the server must have their DNS configured to point to the server's IP address.
