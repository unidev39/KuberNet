# Week 8 / Session 3 - Deploy micro-service to OpenShift

Deploy this application to your OpenShift cluster using **Import from Git**,
then complete the access-control task.

## Part 1 — Project

Create a project "YOUR-NAME_smart-ai-bank" from web UI or via OC:

```
oc new-project devesh-smart-ai-bank
```

<img width="2260" height="1234" alt="Screenshot 2026-07-02 at 1 00 10 PM" src="https://github.com/user-attachments/assets/cb23b070-e207-40be-a6dc-24c817546f0e" />


## Part 2 — Provision Database

In the web console, deploy PostgreSQL using Software Catalog.

### Instantiate Template

<img width="2272" height="1248" alt="Screenshot 2026-07-02 at 1 01 38 PM" src="https://github.com/user-attachments/assets/dd7fdec5-f817-48ef-afb7-7f05eead8c11" />

<img width="2288" height="1244" alt="Screenshot 2026-07-02 at 1 03 31 PM" src="https://github.com/user-attachments/assets/3040c2aa-647e-436f-a17a-f3dfbd5b9e91" />

## Part 3 — Backend

1. In the web console: **+Add → Import from Git**.

<img width="906" height="334" alt="Screenshot 2026-07-02 at 1 05 09 PM" src="https://github.com/user-attachments/assets/d034e703-e69b-477d-b56e-27b5a5d77540" />

If experience the following "rate-limit" issue: 
<img width="800" height="500" alt="image" src="https://github.com/user-attachments/assets/5f2256a0-edbe-4628-854c-4d20d41d7f1e" />

Then, try to fork the repository to your own GitHub account and then use that.

**⚠️ Make sure repository is public**

<img width="750" height="355" alt="Screenshot 2026-07-02 at 4 17 22 PM" src="https://github.com/user-attachments/assets/36adc074-e9f4-4a68-92b7-778000b464f3" />



2. Git repo URL: this repository. Under **Advanced Git options**, set
   **Context dir** to `/backend` (it has its own Dockerfile).

<img width="1150" height="1150" alt="Screenshot 2026-07-02 at 1 06 29 PM" src="https://github.com/user-attachments/assets/cfe2cbf2-bfea-48cb-ab9a-8bae5bb8b9f4" />

4. Name the application `backend`, target port **4000**. A public route is not
   required for the backend.

<img width="1240" height="624" alt="Screenshot 2026-07-02 at 1 07 29 PM" src="https://github.com/user-attachments/assets/9ec65e5a-d486-4f4e-9047-810fa5eb245b" />

   
6. Inject the database configuration into the Deployment:

<img width="1742" height="776" alt="Screenshot 2026-07-02 at 1 13 40 PM" src="https://github.com/user-attachments/assets/1ba0e774-577c-481f-ba74-b2278ce2f48c" />


7. **Run the database migration** from the backend pod (this seeds all
   demo data):

<img width="1838" height="1016" alt="Screenshot 2026-07-02 at 1 14 14 PM" src="https://github.com/user-attachments/assets/e5f2c089-9286-4a65-b8d4-f08657d7fea8" />


   ```bash
   oc rsh deployment/backend npm run migration
   ```

   You should see `✅ Migration complete.` and the list of demo users.

## Part 4 — Frontend

1. **+Add → Import from Git** again, with **Context dir** `/frontend`.

<img width="1208" height="846" alt="Screenshot 2026-07-02 at 1 18 40 PM" src="https://github.com/user-attachments/assets/f385fcf4-df2a-494e-8c0e-5a0480803e98" />

2. Name it `frontend`, target port **3000**, and **create a Route** (this is the
   URL your users open).
3. Tell the frontend where the backend is — the internal Service address:

   ```bash
   oc set env deployment/frontend BACKEND_API_URL=http://backend:4000
   ```
   ⚠️ **IMPORTANT:** The service name must match the backend app name, e.g: smart-ai-bank-app

4. Open the route, log in as `ram` / `customer123`, and try the AI chatbox.
   Then log in as `manager` / `manager123` to see the manager view.

### Verification checklist

- [ ] `oc get pods` shows `db`, `backend`, and `frontend` running.
- [ ] `oc rsh deployment/backend npm run migration` completed successfully.
- [ ] Customer login works and shows balance, KYC, account details, and statement.
- [ ] The chatbox answers a canned question.
- [ ] Manager login shows the branch overview.

## Part 5 — Access control (RBAC)

Configure two users for the cluster:

1. **`developer` user** — may work **only inside the `smart-ai-bank` project**,
   with `edit` permission (deploy and manage apps, but no role management or
   access to other projects):

   ```bash
   oc adm policy add-role-to-user edit developer -n smart-ai-bank
   ```

2. **`admin` user** — retains full cluster access (`cluster-admin`).

Prove it works:

```bash
# As developer — allowed
oc auth can-i create deployments -n smart-ai-bank --as=developer   # yes

# As developer — denied
oc auth can-i create projects --as=developer                       # no
oc auth can-i create deployments -n default --as=developer         # no

# As admin — allowed everywhere
oc auth can-i '*' '*' --as=admin                                   # yes
```

---

## Repository layout

```
├── backend/            # Express REST API + migrations (see backend/Dockerfile)
├── frontend/           # Next.js UI (see frontend/Dockerfile)
├── docker-compose.yml  # Local end-to-end test
└── CLAUDE.md           # Project instructions
```
