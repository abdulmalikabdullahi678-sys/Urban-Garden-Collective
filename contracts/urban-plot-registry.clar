;; Urban Plot Registry
;; Community garden plots and urban farming space documentation

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-EXISTS (err u102))
(define-constant ERR-INVALID-PARAMS (err u103))
(define-constant ERR-INSUFFICIENT-PERMISSIONS (err u104))

;; Data Variables
(define-data-var next-garden-id uint u1)
(define-data-var next-plot-id uint u1)
(define-data-var contract-admin principal CONTRACT-OWNER)

;; Data Maps
(define-map community-gardens
  uint ;; garden-id
  {
    name: (string-ascii 100),
    description: (string-utf8 500),
    total-plots: uint,
    available-plots: uint,
    management-type: (string-ascii 30), ;; "community-managed", "cooperative", "municipal"
    location-coords: (string-ascii 50), ;; GPS coordinates
    established-block: uint,
    manager: principal,
    active: bool
  }
)

(define-map garden-plots
  uint ;; plot-id
  {
    garden-id: uint,
    plot-number: uint,
    size-sqft: uint,
    plot-type: (string-ascii 30), ;; "individual", "shared", "community", "educational"
    soil-quality: (string-ascii 20), ;; "excellent", "good", "fair", "poor"
    water-access: bool,
    sunlight-hours: uint,
    allocated: bool,
    current-user: (optional principal),
    allocation-block: (optional uint)
  }
)

(define-map plot-allocations
  { plot-id: uint, user: principal }
  {
    allocation-date: uint,
    lease-duration: uint,
    crop-plan: (string-ascii 200),
    maintenance-score: uint,
    last-visit: uint,
    active: bool
  }
)

(define-map garden-managers
  { garden-id: uint, manager: principal }
  {
    role: (string-ascii 20), ;; "primary", "assistant", "coordinator"
    appointed-block: uint,
    permissions: (string-ascii 100),
    active: bool
  }
)

(define-map garden-resources
  uint ;; garden-id
  {
    water-source: (string-ascii 50),
    tool-storage: bool,
    composting-area: bool,
    greenhouse: bool,
    parking-spots: uint,
    accessibility-features: (string-ascii 200)
  }
)

(define-map plot-usage-history
  { plot-id: uint, season: uint }
  {
    user: principal,
    crops-grown: (string-ascii 200),
    harvest-yield: uint,
    soil-amendments: (string-ascii 100),
    maintenance-visits: uint
  }
)

(define-map authorized-inspectors principal bool)

;; Private Functions
(define-private (is-contract-admin (user principal))
  (is-eq user (var-get contract-admin))
)

(define-private (is-authorized-inspector (user principal))
  (or
    (is-contract-admin user)
    (default-to false (map-get? authorized-inspectors user))
  )
)

(define-private (is-garden-manager (garden-id uint) (user principal))
  (match (map-get? community-gardens garden-id)
    garden-info (or
      (is-eq user (get manager garden-info))
      (is-some (map-get? garden-managers { garden-id: garden-id, manager: user }))
    )
    false
  )
)

(define-private (increment-garden-id)
  (let ((current-id (var-get next-garden-id)))
    (var-set next-garden-id (+ current-id u1))
    current-id
  )
)

(define-private (increment-plot-id)
  (let ((current-id (var-get next-plot-id)))
    (var-set next-plot-id (+ current-id u1))
    current-id
  )
)

(define-private (validate-garden-data
  (name (string-ascii 100))
  (description (string-utf8 500))
  (total-plots uint)
  (management-type (string-ascii 30))
  (location-coords (string-ascii 50))
)
  (and
    (> (len name) u0)
    (> (len description) u10)
    (> total-plots u0)
    (> (len management-type) u0)
    (> (len location-coords) u0)
  )
)

;; Public Functions

;; Register a new community garden
(define-public (register-garden
  (name (string-ascii 100))
  (description (string-utf8 500))
  (total-plots uint)
  (management-type (string-ascii 30))
  (location-coords (string-ascii 50))
)
  (let
    (
      (garden-id (increment-garden-id))
    )
    (asserts! (validate-garden-data name description total-plots management-type location-coords) ERR-INVALID-PARAMS)
    
    ;; Store garden data
    (map-set community-gardens garden-id {
      name: name,
      description: description,
      total-plots: total-plots,
      available-plots: total-plots,
      management-type: management-type,
      location-coords: location-coords,
      established-block: stacks-block-height,
      manager: tx-sender,
      active: true
    })
    
    ;; Add manager record
    (map-set garden-managers { garden-id: garden-id, manager: tx-sender } {
      role: "primary",
      appointed-block: stacks-block-height,
      permissions: "all-plot-management-resource-allocation",
      active: true
    })
    
    ;; Initialize garden resources
    (map-set garden-resources garden-id {
      water-source: "municipal",
      tool-storage: false,
      composting-area: false,
      greenhouse: false,
      parking-spots: u0,
      accessibility-features: "none"
    })
    
    (ok garden-id)
  )
)

;; Add plot to garden
(define-public (add-plot
  (garden-id uint)
  (plot-number uint)
  (size-sqft uint)
  (plot-type (string-ascii 30))
  (soil-quality (string-ascii 20))
  (water-access bool)
  (sunlight-hours uint)
)
  (let
    (
      (plot-id (increment-plot-id))
    )
    (asserts! (is-some (map-get? community-gardens garden-id)) ERR-NOT-FOUND)
    (asserts! (is-garden-manager garden-id tx-sender) ERR-UNAUTHORIZED)
    (asserts! (> size-sqft u0) ERR-INVALID-PARAMS)
    (asserts! (<= sunlight-hours u12) ERR-INVALID-PARAMS)
    
    ;; Store plot data
    (map-set garden-plots plot-id {
      garden-id: garden-id,
      plot-number: plot-number,
      size-sqft: size-sqft,
      plot-type: plot-type,
      soil-quality: soil-quality,
      water-access: water-access,
      sunlight-hours: sunlight-hours,
      allocated: false,
      current-user: none,
      allocation-block: none
    })
    
    (ok plot-id)
  )
)

;; Allocate plot to user
(define-public (allocate-plot
  (plot-id uint)
  (user principal)
  (lease-duration uint)
  (crop-plan (string-ascii 200))
)
  (let
    (
      (plot-data (unwrap! (map-get? garden-plots plot-id) ERR-NOT-FOUND))
    )
    (asserts! (is-garden-manager (get garden-id plot-data) tx-sender) ERR-UNAUTHORIZED)
    (asserts! (not (get allocated plot-data)) ERR-ALREADY-EXISTS)
    (asserts! (> lease-duration u0) ERR-INVALID-PARAMS)
    
    ;; Update plot as allocated
    (map-set garden-plots plot-id
      (merge plot-data {
        allocated: true,
        current-user: (some user),
        allocation-block: (some stacks-block-height)
      })
    )
    
    ;; Create allocation record
    (map-set plot-allocations { plot-id: plot-id, user: user } {
      allocation-date: stacks-block-height,
      lease-duration: lease-duration,
      crop-plan: crop-plan,
      maintenance-score: u100,
      last-visit: stacks-block-height,
      active: true
    })
    
    ;; Update garden available plots
    (let
      (
        (garden-data (unwrap! (map-get? community-gardens (get garden-id plot-data)) ERR-NOT-FOUND))
      )
      (map-set community-gardens (get garden-id plot-data)
        (merge garden-data {
          available-plots: (if (> (get available-plots garden-data) u0)
                               (- (get available-plots garden-data) u1)
                               u0)
        })
      )
    )
    
    (ok true)
  )
)

;; Release plot allocation
(define-public (release-plot (plot-id uint))
  (let
    (
      (plot-data (unwrap! (map-get? garden-plots plot-id) ERR-NOT-FOUND))
      (current-user (unwrap! (get current-user plot-data) ERR-NOT-FOUND))
    )
    (asserts! (or
      (is-eq tx-sender current-user)
      (is-garden-manager (get garden-id plot-data) tx-sender)
      (is-authorized-inspector tx-sender)
    ) ERR-UNAUTHORIZED)
    
    ;; Update plot as available
    (map-set garden-plots plot-id
      (merge plot-data {
        allocated: false,
        current-user: none,
        allocation-block: none
      })
    )
    
    ;; Deactivate allocation record
    (map-set plot-allocations { plot-id: plot-id, user: current-user }
      (merge
        (unwrap! (map-get? plot-allocations { plot-id: plot-id, user: current-user }) ERR-NOT-FOUND)
        { active: false }
      )
    )
    
    ;; Update garden available plots
    (let
      (
        (garden-data (unwrap! (map-get? community-gardens (get garden-id plot-data)) ERR-NOT-FOUND))
      )
      (map-set community-gardens (get garden-id plot-data)
        (merge garden-data {
          available-plots: (+ (get available-plots garden-data) u1)
        })
      )
    )
    
    (ok true)
  )
)

;; Update garden resources
(define-public (update-garden-resources
  (garden-id uint)
  (water-source (string-ascii 50))
  (tool-storage bool)
  (composting-area bool)
  (greenhouse bool)
  (parking-spots uint)
  (accessibility-features (string-ascii 200))
)
  (begin
    (asserts! (is-some (map-get? community-gardens garden-id)) ERR-NOT-FOUND)
    (asserts! (is-garden-manager garden-id tx-sender) ERR-UNAUTHORIZED)
    
    (map-set garden-resources garden-id {
      water-source: water-source,
      tool-storage: tool-storage,
      composting-area: composting-area,
      greenhouse: greenhouse,
      parking-spots: parking-spots,
      accessibility-features: accessibility-features
    })
    
    (ok true)
  )
)

;; Record plot usage for season
(define-public (record-plot-usage
  (plot-id uint)
  (season uint)
  (crops-grown (string-ascii 200))
  (harvest-yield uint)
  (soil-amendments (string-ascii 100))
  (maintenance-visits uint)
)
  (let
    (
      (plot-data (unwrap! (map-get? garden-plots plot-id) ERR-NOT-FOUND))
      (current-user (unwrap! (get current-user plot-data) ERR-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender current-user) ERR-UNAUTHORIZED)
    
    (map-set plot-usage-history { plot-id: plot-id, season: season } {
      user: current-user,
      crops-grown: crops-grown,
      harvest-yield: harvest-yield,
      soil-amendments: soil-amendments,
      maintenance-visits: maintenance-visits
    })
    
    (ok true)
  )
)

;; Appoint garden manager
(define-public (appoint-manager
  (garden-id uint)
  (manager principal)
  (role (string-ascii 20))
  (permissions (string-ascii 100))
)
  (let
    (
      (garden-data (unwrap! (map-get? community-gardens garden-id) ERR-NOT-FOUND))
    )
    (asserts! (or
      (is-eq tx-sender (get manager garden-data))
      (is-contract-admin tx-sender)
    ) ERR-UNAUTHORIZED)
    
    (map-set garden-managers { garden-id: garden-id, manager: manager } {
      role: role,
      appointed-block: stacks-block-height,
      permissions: permissions,
      active: true
    })
    
    (ok true)
  )
)

;; Authorize inspector (admin only)
(define-public (authorize-inspector (inspector principal))
  (begin
    (asserts! (is-contract-admin tx-sender) ERR-UNAUTHORIZED)
    (map-set authorized-inspectors inspector true)
    (ok true)
  )
)

;; Read-only Functions

;; Get garden information
(define-read-only (get-garden (garden-id uint))
  (map-get? community-gardens garden-id)
)

;; Get plot information
(define-read-only (get-plot (plot-id uint))
  (map-get? garden-plots plot-id)
)

;; Get plot allocation
(define-read-only (get-plot-allocation (plot-id uint) (user principal))
  (map-get? plot-allocations { plot-id: plot-id, user: user })
)

;; Get garden manager info
(define-read-only (get-manager-info (garden-id uint) (manager principal))
  (map-get? garden-managers { garden-id: garden-id, manager: manager })
)

;; Get garden resources
(define-read-only (get-garden-resources (garden-id uint))
  (map-get? garden-resources garden-id)
)

;; Get plot usage history
(define-read-only (get-plot-usage (plot-id uint) (season uint))
  (map-get? plot-usage-history { plot-id: plot-id, season: season })
)

;; Check if inspector is authorized
(define-read-only (is-inspector-authorized (inspector principal))
  (is-authorized-inspector inspector)
)

;; Get contract admin
(define-read-only (get-contract-admin)
  (var-get contract-admin)
)

;; Get next IDs
(define-read-only (get-next-garden-id)
  (var-get next-garden-id)
)

(define-read-only (get-next-plot-id)
  (var-get next-plot-id)
)
