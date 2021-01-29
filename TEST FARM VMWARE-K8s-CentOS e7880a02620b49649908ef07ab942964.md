# TEST FARM VMWARE-K8s-CentOS

Created: Jan 22, 2021 9:26 AM
Created By: Filippo Rigoni
Last Edited By: Filippo Rigoni
Last Edited Time: Jan 22, 2021 9:50 AM
Stakeholders: Filippo Rigoni
Status: In Progress 🙌
Type: ToDO

# Summary

Test installazione di un Cluster Kubernetes in VMware Workstation 

# Background

What is the motivation for these changes? What problems will this solve? Include graphs, metrics, etc. if relevant. 

- 

# Goals

What are the outcomes that will result from these changes? How will we evaluate success for the proposed changes? 

- 

### Non-Goals

To narrow the scope of what we're working on, outline what this proposal will not accomplish.

- 

# Proposed Solution

Describe the solution to the problems outlined above. Include enough detail to allow for productive discussion and comments from readers.

- 

### Risks

Highlight risks so your reviewers can direct their attention here. 

- 

### Milestones

Break down the solution into key tasks and their estimated deadlines. 

- 

### Open Questions

Ask any unresolved questions about the proposed solution here.

- 

# Follow-up Tasks

What needs to be done next for this proposal? 

- [ ]  
- [ ]  
- [ ]  

# Task list - Summary

* Setup locale di VMWARE WORKSTATION 15 in windows 10

* Installazione 4 VM CENTOS 8.2.3 - (1 - Master Node - 2 Worker Nodes - 1 Harbor registry) 

* Aggiornamento e primo Setup Network delle VM e test di connettività sulle due LAN (host-only interna) e NAT (esterna).

* Installazione requirements su tutte le VM : Docker engine  &  Containerd  + Kubernetes +Wavenet & Multus CNI plugins