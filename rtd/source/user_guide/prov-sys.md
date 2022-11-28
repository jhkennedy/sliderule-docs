# Provisioning System
The provisioning system allows different organizations to share a given amazon web services account. Each organization has a cluster of sliderule nodes. The provisioning sytem provides owners of organizations the ability to control access to the organization cluster via privilaged 'owner' accounts.

### Owner accounts:
1) deploy or shutdown the organization cluster 
2) can accept users' membership requests
3) make memberships active or inactive
4) limit the number of nodes that can be deployed on the organization cluster
5) specify the minimum number of nodes that are deployed


Regular users of sliderule can create a regular account and request membership to organizations. The owner of the organization can accept the membership and make the user an ***active*** member or ignore the request. Owners can make members inactive to temporarily deny access to the cluster. Active members can obtain an access token that provides access to the system for 24 hours. Active members can request node capacity for the duration of the token lifetime or with a provided "time to live". 

## Endpoints:

The provisioning system provides endpoints that allow the user to ensure sufficient server resources are allocated for their python client to use throughout a given session. All request for node capacity have an expiration. They are combined so that each and every users' requests for the minimum number of nodes required are honored. When all the node capacity requests have expired the provisioning system will automatically reduce the number of nodes in the cluster to the minimum it is configured for. Organization clusters can have two nodes (a load balancer and a monitor) that are always active even if the worker nodes is set to zero. The load balancer node can take several minutes to start. The organization cluster can be configured to destroy the overhead nodes if the minimum number of nodes is zero or to keep them active for faster deployment. The organization cluster can also be configured to deploy automatically (if the overhead nodes were configured to be destroyed) upon the first node capacity request. When the load balancer has to be started it will take longer to make the cluster completely available to the users' client. However this tradeoff can save money if the organization cluster is expected to be idle for long periods of time.

 

## Endpoints used by members to provision and enquire about resources:
There are no open endpoints. All enpoints require Authentication.

### Endpoints that require Username/Password Authentication

* [Obtain an access token](prov-sys/org_token.md) : `POST ps.{{DOMAIN}}/api/org_token/`

### Endpoints that require Access Token Authentication

These endpoints require a valid access token to be included in the header of the request. A Token can be acquired from the Login view above.

### Cluster node management

These endpoints provide node capacity management as requested by a member whose Token is provided with the request:

* [Get min/max and current number of Nodes](prov-sys/org_nn.md) : `GET ps.{{DOMAIN}}/api/org_num_nodes/<str:org_name>/`

* [Request minimum node capacity with token expiration](prov-sys/desired_onn.md) : `PUT ps.{DOMAIN}/api/desired_org_num_nodes/<str:org_name>/<int:desired_num_nodes>/`

* [Request minimum node capacity with TTL expiration](prov-sys/desired_onnttl.md) : `PUT ps.{DOMAIN}/api/desired_org_num_nodes_ttl/<str:org_name>/<int:desired_num_nodes>/<int:ttl>/`

* [Remove pending node capacity requests](prov-sys/remove_donn.md) : `PUT ps.{DOMAIN}/api/remove_org_num_nodes_reqs/<str:org_name>/`

* [Get Membership status](prov-sys/membership.md) : `GET ps.{DOMAIN}/api/membership_status/<str:org_name>/`

## Endpoints that require Refresh Token

* [Refresh an access token](prov-sys/refresh_token.md) : `POST ps.{{DOMAIN}}/api/org_token/refresh`

* [Blacklist a refresh token](prov-sys/blacklist_refresh_token.md) : `POST ps.{{DOMAIN}}/api/token/blacklist`


