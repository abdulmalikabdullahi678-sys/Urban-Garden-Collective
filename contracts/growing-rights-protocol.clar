;; Growing Rights Protocol
;; Urban agriculture access and food sovereignty enforcement

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u200))
(define-constant ERR-NOT-FOUND (err u201))
(define-constant ERR-ALREADY-EXISTS (err u202))
(define-constant ERR-INVALID-PARAMS (err u203))
(define-constant ERR-INSUFFICIENT-RIGHTS (err u204))
(define-constant ERR-ACCESS-DENIED (err u205))
(define-constant ERR-RESOURCE-UNAVAILABLE (err u206))

;; Data Variables
(define-data-var next-member-id uint u1)
(define-data-var next-resource-id uint u1)
(define-data-var next-dispute-id uint u1)
(define-data-var contract-admin principal CONTRACT-OWNER)

;; Data Maps
(define-map community-members
  principal
  {
    member-id: uint,
    name: (string-ascii 100),
    experience-level: (string-ascii 20), ;; "beginner", "intermediate", "advanced", "expert"
    specializations: (string-ascii 200),
    join-date: uint,
    contribution-score: uint,
    active-plots: uint,
    reputation: uint,
    verified: bool
  }
)

(define-map growing-rights
  principal
  {
    food-sovereignty-rights: bool,
    plot-allocation-rights: bool,
    resource-sharing-rights: bool,
    seed-saving-rights: bool,
    composting-rights: bool,
    tool-access-rights: bool,
    water-access-rights: bool,
    educational-rights: bool,
    rights-granted-date: uint
  }
)

(define-map resource-allocations
  uint ;; resource-id
  {
    resource-type: (string-ascii 30), ;; "water", "tools", "seeds", "compost", "storage"
    resource-name: (string-ascii 100),
    garden-id: uint,
    total-capacity: uint,
    available-capacity: uint,
    allocation-unit: (string-ascii 20), ;; "hours", "gallons", "pounds", "square-feet"
    cost-per-unit: uint,
    managed-by: principal,
    active: bool
  }
)

(define-map member-resource-usage
  { member: principal, resource-id: uint }
  {
    allocated-amount: uint,
    used-amount: uint,
    allocation-date: uint,
    expiry-date: uint,
    payment-due: uint,
    payment-paid: uint,
    active: bool
  }
)

(define-map food-sovereignty-claims
  { member: principal, garden-id: uint }
  {
    claim-type: (string-ascii 30), ;; "cultural-crops", "medicinal-plants", "traditional-varieties"
    crop-varieties: (string-ascii 300),
    cultural-significance: (string-utf8 500),
    protection-level: (string-ascii 20), ;; "basic", "protected", "sacred"
    claim-date: uint,
    approved: bool,
    approved-by: (optional principal)
  }
)

(define-map community-governance
  uint ;; garden-id
  {
    governance-model: (string-ascii 30), ;; "consensus", "majority", "delegated", "council"
    voting-members: uint,
    decision-threshold: uint,
    proposal-period: uint,
    implementation-period: uint,
    last-election: uint
  }
)

(define-map access-permissions
  { member: principal, garden-id: uint }
  {
    access-level: (string-ascii 20), ;; "visitor", "member", "steward", "coordinator"
    granted-by: principal,
    granted-date: uint,
    expiry-date: (optional uint),
    conditions: (string-ascii 200),
    violations: uint
  }
)

(define-map disputes
  uint ;; dispute-id
  {
    garden-id: uint,
    complainant: principal,
    respondent: principal,
    dispute-type: (string-ascii 40), ;; "plot-boundary", "resource-access", "governance-violation"
    description: (string-utf8 1000),
    evidence: (optional (string-ascii 300)),
    filed-date: uint,
    status: (string-ascii 20), ;; "open", "mediation", "arbitration", "resolved"
    mediator: (optional principal),
    resolution: (optional (string-utf8 500)),
    resolution-date: (optional uint)
  }
)

(define-map authorized-mediators principal bool)

;; Private Functions
(define-private (is-contract-admin (user principal))
  (is-eq user (var-get contract-admin))
)

(define-private (is-authorized-mediator (user principal))
  (or
    (is-contract-admin user)
    (default-to false (map-get? authorized-mediators user))
  )
)

(define-private (is-community-member (user principal))
  (is-some (map-get? community-members user))
)

(define-private (has-growing-rights (user principal) (right-type (string-ascii 30)))
  (match (map-get? growing-rights user)
    rights-info (if (is-eq right-type "food-sovereignty")
      (get food-sovereignty-rights rights-info)
      (if (is-eq right-type "plot-allocation")
        (get plot-allocation-rights rights-info)
        (if (is-eq right-type "resource-sharing")
          (get resource-sharing-rights rights-info)
          (if (is-eq right-type "seed-saving")
            (get seed-saving-rights rights-info)
            (if (is-eq right-type "composting")
              (get composting-rights rights-info)
              (if (is-eq right-type "tool-access")
                (get tool-access-rights rights-info)
                (if (is-eq right-type "water-access")
                  (get water-access-rights rights-info)
                  (if (is-eq right-type "educational")
                    (get educational-rights rights-info)
                    false
                  )
                )
              )
            )
          )
        )
      )
    )
    false
  )
)

(define-private (increment-member-id)
  (let ((current-id (var-get next-member-id)))
    (var-set next-member-id (+ current-id u1))
    current-id
  )
)

(define-private (increment-resource-id)
  (let ((current-id (var-get next-resource-id)))
    (var-set next-resource-id (+ current-id u1))
    current-id
  )
)

(define-private (increment-dispute-id)
  (let ((current-id (var-get next-dispute-id)))
    (var-set next-dispute-id (+ current-id u1))
    current-id
  )
)

;; Public Functions

;; Register as community member
(define-public (register-member
  (name (string-ascii 100))
  (experience-level (string-ascii 20))
  (specializations (string-ascii 200))
)
  (let
    (
      (member-id (increment-member-id))
    )
    (asserts! (not (is-community-member tx-sender)) ERR-ALREADY-EXISTS)
    (asserts! (> (len name) u0) ERR-INVALID-PARAMS)
    (asserts! (> (len experience-level) u0) ERR-INVALID-PARAMS)
    
    ;; Create member profile
    (map-set community-members tx-sender {
      member-id: member-id,
      name: name,
      experience-level: experience-level,
      specializations: specializations,
      join-date: stacks-block-height,
      contribution-score: u0,
      active-plots: u0,
      reputation: u100,
      verified: false
    })
    
    ;; Grant basic growing rights
    (map-set growing-rights tx-sender {
      food-sovereignty-rights: true,
      plot-allocation-rights: false, ;; must be granted by community
      resource-sharing-rights: true,
      seed-saving-rights: true,
      composting-rights: true,
      tool-access-rights: false, ;; must be granted by community
      water-access-rights: false, ;; must be granted by community
      educational-rights: true,
      rights-granted-date: stacks-block-height
    })
    
    (ok member-id)
  )
)

;; Grant specific growing rights
(define-public (grant-growing-rights
  (member principal)
  (right-type (string-ascii 30))
  (garden-id uint)
)
  (begin
    (asserts! (is-community-member member) ERR-NOT-FOUND)
    (asserts! (or
      (is-contract-admin tx-sender)
      ;; Additional garden manager check would go here
      false
    ) ERR-UNAUTHORIZED)
    
    (let
      (
        (current-rights (unwrap! (map-get? growing-rights member) ERR-NOT-FOUND))
      )
      (if (is-eq right-type "plot-allocation")
        (map-set growing-rights member
          (merge current-rights { plot-allocation-rights: true }))
        (if (is-eq right-type "tool-access")
          (map-set growing-rights member
            (merge current-rights { tool-access-rights: true }))
          (if (is-eq right-type "water-access")
            (map-set growing-rights member
              (merge current-rights { water-access-rights: true }))
            false ;; Unknown right type
          )
        )
      )
    )
    
    (ok true)
  )
)

;; Allocate resource to member
(define-public (allocate-resource
  (resource-id uint)
  (member principal)
  (amount uint)
  (duration-blocks uint)
)
  (let
    (
      (resource-info (unwrap! (map-get? resource-allocations resource-id) ERR-NOT-FOUND))
    )
    (asserts! (is-community-member member) ERR-NOT-FOUND)
    (asserts! (has-growing-rights member "resource-sharing") ERR-INSUFFICIENT-RIGHTS)
    (asserts! (>= (get available-capacity resource-info) amount) ERR-RESOURCE-UNAVAILABLE)
    
    ;; Update resource availability
    (map-set resource-allocations resource-id
      (merge resource-info {
        available-capacity: (- (get available-capacity resource-info) amount)
      })
    )
    
    ;; Create member resource usage record
    (map-set member-resource-usage { member: member, resource-id: resource-id } {
      allocated-amount: amount,
      used-amount: u0,
      allocation-date: stacks-block-height,
      expiry-date: (+ stacks-block-height duration-blocks),
      payment-due: (* amount (get cost-per-unit resource-info)),
      payment-paid: u0,
      active: true
    })
    
    (ok true)
  )
)

;; Register resource
(define-public (register-resource
  (resource-type (string-ascii 30))
  (resource-name (string-ascii 100))
  (garden-id uint)
  (total-capacity uint)
  (allocation-unit (string-ascii 20))
  (cost-per-unit uint)
)
  (let
    (
      (resource-id (increment-resource-id))
    )
    (asserts! (> (len resource-name) u0) ERR-INVALID-PARAMS)
    (asserts! (> total-capacity u0) ERR-INVALID-PARAMS)
    
    (map-set resource-allocations resource-id {
      resource-type: resource-type,
      resource-name: resource-name,
      garden-id: garden-id,
      total-capacity: total-capacity,
      available-capacity: total-capacity,
      allocation-unit: allocation-unit,
      cost-per-unit: cost-per-unit,
      managed-by: tx-sender,
      active: true
    })
    
    (ok resource-id)
  )
)

;; File food sovereignty claim
(define-public (file-food-sovereignty-claim
  (garden-id uint)
  (claim-type (string-ascii 30))
  (crop-varieties (string-ascii 300))
  (cultural-significance (string-utf8 500))
  (protection-level (string-ascii 20))
)
  (begin
    (asserts! (is-community-member tx-sender) ERR-NOT-FOUND)
    (asserts! (has-growing-rights tx-sender "food-sovereignty") ERR-INSUFFICIENT-RIGHTS)
    (asserts! (> (len crop-varieties) u0) ERR-INVALID-PARAMS)
    
    (map-set food-sovereignty-claims { member: tx-sender, garden-id: garden-id } {
      claim-type: claim-type,
      crop-varieties: crop-varieties,
      cultural-significance: cultural-significance,
      protection-level: protection-level,
      claim-date: stacks-block-height,
      approved: false,
      approved-by: none
    })
    
    (ok true)
  )
)

;; Grant access permissions
(define-public (grant-access
  (member principal)
  (garden-id uint)
  (access-level (string-ascii 20))
  (conditions (string-ascii 200))
  (expiry-blocks (optional uint))
)
  (let
    (
      (expiry-date (match expiry-blocks
        blocks (some (+ stacks-block-height blocks))
        none
      ))
    )
    (asserts! (is-community-member member) ERR-NOT-FOUND)
    ;; Additional authorization checks would go here
    
    (map-set access-permissions { member: member, garden-id: garden-id } {
      access-level: access-level,
      granted-by: tx-sender,
      granted-date: stacks-block-height,
      expiry-date: expiry-date,
      conditions: conditions,
      violations: u0
    })
    
    (ok true)
  )
)

;; File dispute
(define-public (file-dispute
  (garden-id uint)
  (respondent principal)
  (dispute-type (string-ascii 40))
  (description (string-utf8 1000))
  (evidence (optional (string-ascii 300)))
)
  (let
    (
      (dispute-id (increment-dispute-id))
    )
    (asserts! (is-community-member tx-sender) ERR-NOT-FOUND)
    (asserts! (not (is-eq tx-sender respondent)) ERR-INVALID-PARAMS)
    
    (map-set disputes dispute-id {
      garden-id: garden-id,
      complainant: tx-sender,
      respondent: respondent,
      dispute-type: dispute-type,
      description: description,
      evidence: evidence,
      filed-date: stacks-block-height,
      status: "open",
      mediator: none,
      resolution: none,
      resolution-date: none
    })
    
    (ok dispute-id)
  )
)

;; Resolve dispute
(define-public (resolve-dispute
  (dispute-id uint)
  (resolution (string-utf8 500))
  (status (string-ascii 20))
)
  (let
    (
      (dispute-info (unwrap! (map-get? disputes dispute-id) ERR-NOT-FOUND))
    )
    (asserts! (is-authorized-mediator tx-sender) ERR-UNAUTHORIZED)
    
    (map-set disputes dispute-id
      (merge dispute-info {
        status: status,
        mediator: (some tx-sender),
        resolution: (some resolution),
        resolution-date: (some stacks-block-height)
      })
    )
    
    (ok true)
  )
)

;; Update member contribution score
(define-public (update-contribution-score
  (member principal)
  (score-change int)
)
  (let
    (
      (member-info (unwrap! (map-get? community-members member) ERR-NOT-FOUND))
    )
    ;; Additional authorization checks would go here
    
    (map-set community-members member
      (merge member-info {
        contribution-score: (if (> score-change 0)
                              (+ (get contribution-score member-info) (to-uint score-change))
                              (if (> (get contribution-score member-info) (to-uint (- 0 score-change)))
                                (- (get contribution-score member-info) (to-uint (- 0 score-change)))
                                u0
                              )
                            )
      })
    )
    
    (ok true)
  )
)

;; Verify member (admin only)
(define-public (verify-member (member principal))
  (let
    (
      (member-info (unwrap! (map-get? community-members member) ERR-NOT-FOUND))
    )
    (asserts! (is-contract-admin tx-sender) ERR-UNAUTHORIZED)
    
    (map-set community-members member
      (merge member-info { verified: true })
    )
    
    (ok true)
  )
)

;; Authorize mediator (admin only)
(define-public (authorize-mediator (mediator principal))
  (begin
    (asserts! (is-contract-admin tx-sender) ERR-UNAUTHORIZED)
    (map-set authorized-mediators mediator true)
    (ok true)
  )
)

;; Read-only Functions

;; Get member info
(define-read-only (get-member-info (member principal))
  (map-get? community-members member)
)

;; Get growing rights
(define-read-only (get-growing-rights (member principal))
  (map-get? growing-rights member)
)

;; Get resource allocation
(define-read-only (get-resource-allocation (resource-id uint))
  (map-get? resource-allocations resource-id)
)

;; Get member resource usage
(define-read-only (get-member-resource-usage (member principal) (resource-id uint))
  (map-get? member-resource-usage { member: member, resource-id: resource-id })
)

;; Get food sovereignty claim
(define-read-only (get-food-sovereignty-claim (member principal) (garden-id uint))
  (map-get? food-sovereignty-claims { member: member, garden-id: garden-id })
)

;; Get access permissions
(define-read-only (get-access-permissions (member principal) (garden-id uint))
  (map-get? access-permissions { member: member, garden-id: garden-id })
)

;; Get dispute info
(define-read-only (get-dispute (dispute-id uint))
  (map-get? disputes dispute-id)
)

;; Check if user is authorized mediator
(define-read-only (is-mediator-authorized (mediator principal))
  (is-authorized-mediator mediator)
)

;; Get contract admin
(define-read-only (get-contract-admin)
  (var-get contract-admin)
)

;; Get next IDs
(define-read-only (get-next-member-id)
  (var-get next-member-id)
)

(define-read-only (get-next-resource-id)
  (var-get next-resource-id)
)

(define-read-only (get-next-dispute-id)
  (var-get next-dispute-id)
)
