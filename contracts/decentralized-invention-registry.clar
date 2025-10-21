(define-constant ERR_UNAUTHORIZED u401)
(define-constant ERR_INVENTION_NOT_FOUND u402)
(define-constant ERR_ALREADY_REGISTERED u403)
(define-constant ERR_INVALID_LICENSE u404)
(define-constant ERR_LICENSE_EXPIRED u405)
(define-constant ERR_INSUFFICIENT_PAYMENT u406)
(define-constant ERR_INVALID_OWNERSHIP u407)
(define-constant ERR_VERIFICATION_FAILED u408)
(define-constant ERR_INVALID_AMOUNT u409)
(define-constant ERR_TRANSFER_FAILED u410)

(define-constant INVENTION_STATUS_PENDING u0)
(define-constant INVENTION_STATUS_VERIFIED u1)
(define-constant INVENTION_STATUS_LICENSED u2)
(define-constant INVENTION_STATUS_EXPIRED u3)
(define-constant INVENTION_STATUS_DISPUTED u4)

(define-constant LICENSE_TYPE_EXCLUSIVE u0)
(define-constant LICENSE_TYPE_NON_EXCLUSIVE u1)
(define-constant LICENSE_TYPE_COMMERCIAL u2)
(define-constant LICENSE_TYPE_ACADEMIC u3)

(define-constant PATENT_DURATION u525600)
(define-constant VERIFICATION_PERIOD u1440)
(define-constant REGISTRATION_FEE u1000000)

(define-data-var invention-counter uint u0)
(define-data-var license-counter uint u0)
(define-data-var total-registry-fees uint u0)
(define-data-var contract-owner principal tx-sender)

(define-map inventions uint {
    inventor: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    category: (string-ascii 50),
    registration-date: uint,
    expiry-date: uint,
    status: uint,
    verification-hash: (optional (string-ascii 64)),
    license-fee: uint,
    total-licenses: uint,
    total-revenue: uint
})

(define-map invention-licenses { invention-id: uint, licensee: principal } {
    license-type: uint,
    license-fee: uint,
    license-date: uint,
    expiry-date: uint,
    active: bool
})

(define-map invention-ownership uint {
    owner: principal,
    ownership-percentage: uint,
    transfer-date: uint
})

(define-map invention-verifications { invention-id: uint, verifier: principal } {
    verification-date: uint,
    verification-result: bool,
    verification-notes: (string-ascii 200)
})

(define-map user-profiles principal {
    inventions-registered: uint,
    inventions-licensed: uint,
    total-revenue-earned: uint,
    reputation-score: uint,
    verification-count: uint
})

(define-map category-stats (string-ascii 50) {
    total-inventions: uint,
    verified-inventions: uint,
    total-licenses: uint
})

(define-public (register-invention (title (string-ascii 100)) (description (string-ascii 500)) (category (string-ascii 50)) (license-fee uint))
    (let (
        (invention-id (+ (var-get invention-counter) u1))
        (registration-date burn-block-height)
        (expiry-date (+ burn-block-height PATENT_DURATION))
    )
        (asserts! (> license-fee u0) (err ERR_INVALID_AMOUNT))
        (try! (stx-transfer? REGISTRATION_FEE tx-sender (as-contract tx-sender)))
        
        (map-set inventions invention-id {
            inventor: tx-sender,
            title: title,
            description: description,
            category: category,
            registration-date: registration-date,
            expiry-date: expiry-date,
            status: INVENTION_STATUS_PENDING,
            verification-hash: none,
            license-fee: license-fee,
            total-licenses: u0,
            total-revenue: u0
        })
        
        (map-set invention-ownership invention-id {
            owner: tx-sender,
            ownership-percentage: u100,
            transfer-date: registration-date
        })
        
        (var-set invention-counter invention-id)
        (var-set total-registry-fees (+ (var-get total-registry-fees) REGISTRATION_FEE))
        (update-user-profile-registration tx-sender)
        (update-category-stats category u1 u0 u0)
        (ok invention-id)
    )
)

(define-public (verify-invention (invention-id uint) (verification-hash (string-ascii 64)) (verification-result bool) (notes (string-ascii 200)))
    (let (
        (invention (unwrap! (map-get? inventions invention-id) (err ERR_INVENTION_NOT_FOUND)))
    )
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))
        (asserts! (is-eq (get status invention) INVENTION_STATUS_PENDING) (err ERR_VERIFICATION_FAILED))
        
        (map-set invention-verifications { invention-id: invention-id, verifier: tx-sender } {
            verification-date: burn-block-height,
            verification-result: verification-result,
            verification-notes: notes
        })
        
        (if verification-result
            (begin
                (map-set inventions invention-id (merge invention {
                    status: INVENTION_STATUS_VERIFIED,
                    verification-hash: (some verification-hash)
                }))
                (update-category-stats (get category invention) u0 u1 u0)
                (update-user-profile-verification tx-sender)
                (ok true)
            )
            (begin
                (map-set inventions invention-id (merge invention { status: INVENTION_STATUS_DISPUTED }))
                (ok false)
            )
        )
    )
)

(define-public (license-invention (invention-id uint) (license-type uint))
    (let (
        (invention (unwrap! (map-get? inventions invention-id) (err ERR_INVENTION_NOT_FOUND)))
        (license-fee (get license-fee invention))
        (ownership (unwrap! (map-get? invention-ownership invention-id) (err ERR_INVALID_OWNERSHIP)))
        (owner (get owner ownership))
        (expiry-date (+ burn-block-height PATENT_DURATION))
    )
        (asserts! (is-eq (get status invention) INVENTION_STATUS_VERIFIED) (err ERR_VERIFICATION_FAILED))
        (asserts! (< burn-block-height (get expiry-date invention)) (err ERR_LICENSE_EXPIRED))
        (asserts! (is-none (map-get? invention-licenses { invention-id: invention-id, licensee: tx-sender })) (err ERR_ALREADY_REGISTERED))
        
        (try! (stx-transfer? license-fee tx-sender owner))
        
        (map-set invention-licenses { invention-id: invention-id, licensee: tx-sender } {
            license-type: license-type,
            license-fee: license-fee,
            license-date: burn-block-height,
            expiry-date: expiry-date,
            active: true
        })
        
        (map-set inventions invention-id (merge invention {
            total-licenses: (+ (get total-licenses invention) u1),
            total-revenue: (+ (get total-revenue invention) license-fee),
            status: INVENTION_STATUS_LICENSED
        }))
        
        (update-user-profile-licensing tx-sender)
        (update-user-profile-revenue owner license-fee)
        (update-category-stats (get category invention) u0 u0 u1)
        (ok true)
    )
)

(define-public (transfer-ownership (invention-id uint) (new-owner principal) (percentage uint))
    (let (
        (invention (unwrap! (map-get? inventions invention-id) (err ERR_INVENTION_NOT_FOUND)))
        (current-ownership (unwrap! (map-get? invention-ownership invention-id) (err ERR_INVALID_OWNERSHIP)))
    )
        (asserts! (is-eq tx-sender (get owner current-ownership)) (err ERR_UNAUTHORIZED))
        (asserts! (> percentage u0) (err ERR_INVALID_AMOUNT))
        (asserts! (<= percentage u100) (err ERR_INVALID_AMOUNT))
        
        (map-set invention-ownership invention-id {
            owner: new-owner,
            ownership-percentage: percentage,
            transfer-date: burn-block-height
        })
        
        (ok true)
    )
)

(define-public (update-license-fee (invention-id uint) (new-fee uint))
    (let (
        (invention (unwrap! (map-get? inventions invention-id) (err ERR_INVENTION_NOT_FOUND)))
        (ownership (unwrap! (map-get? invention-ownership invention-id) (err ERR_INVALID_OWNERSHIP)))
    )
        (asserts! (is-eq tx-sender (get owner ownership)) (err ERR_UNAUTHORIZED))
        (asserts! (> new-fee u0) (err ERR_INVALID_AMOUNT))
        
        (map-set inventions invention-id (merge invention { license-fee: new-fee }))
        (ok true)
    )
)

(define-public (revoke-license (invention-id uint) (licensee principal))
    (let (
        (invention (unwrap! (map-get? inventions invention-id) (err ERR_INVENTION_NOT_FOUND)))
        (ownership (unwrap! (map-get? invention-ownership invention-id) (err ERR_INVALID_OWNERSHIP)))
        (license (unwrap! (map-get? invention-licenses { invention-id: invention-id, licensee: licensee }) (err ERR_INVALID_LICENSE)))
    )
        (asserts! (is-eq tx-sender (get owner ownership)) (err ERR_UNAUTHORIZED))
        (asserts! (get active license) (err ERR_INVALID_LICENSE))
        
        (map-set invention-licenses { invention-id: invention-id, licensee: licensee } 
                 (merge license { active: false }))
        (ok true)
    )
)

(define-public (renew-patent (invention-id uint))
    (let (
        (invention (unwrap! (map-get? inventions invention-id) (err ERR_INVENTION_NOT_FOUND)))
        (ownership (unwrap! (map-get? invention-ownership invention-id) (err ERR_INVALID_OWNERSHIP)))
        (renewal-fee (/ REGISTRATION_FEE u2))
        (new-expiry (+ burn-block-height PATENT_DURATION))
    )
        (asserts! (is-eq tx-sender (get owner ownership)) (err ERR_UNAUTHORIZED))
        (asserts! (>= burn-block-height (get expiry-date invention)) (err ERR_INVALID_AMOUNT))
        
        (try! (stx-transfer? renewal-fee tx-sender (as-contract tx-sender)))
        
        (map-set inventions invention-id (merge invention {
            expiry-date: new-expiry,
            status: INVENTION_STATUS_VERIFIED
        }))
        
        (var-set total-registry-fees (+ (var-get total-registry-fees) renewal-fee))
        (ok true)
    )
)

(define-private (update-user-profile-registration (user principal))
    (let (
        (current-profile (default-to { inventions-registered: u0, inventions-licensed: u0, total-revenue-earned: u0, reputation-score: u0, verification-count: u0 } 
                         (map-get? user-profiles user)))
    )
        (map-set user-profiles user (merge current-profile { 
            inventions-registered: (+ (get inventions-registered current-profile) u1),
            reputation-score: (+ (get reputation-score current-profile) u10)
        }))
        true
    )
)

(define-private (update-user-profile-licensing (user principal))
    (let (
        (current-profile (default-to { inventions-registered: u0, inventions-licensed: u0, total-revenue-earned: u0, reputation-score: u0, verification-count: u0 } 
                         (map-get? user-profiles user)))
    )
        (map-set user-profiles user (merge current-profile { 
            inventions-licensed: (+ (get inventions-licensed current-profile) u1),
            reputation-score: (+ (get reputation-score current-profile) u5)
        }))
        true
    )
)

(define-private (update-user-profile-revenue (user principal) (amount uint))
    (let (
        (current-profile (default-to { inventions-registered: u0, inventions-licensed: u0, total-revenue-earned: u0, reputation-score: u0, verification-count: u0 } 
                         (map-get? user-profiles user)))
    )
        (map-set user-profiles user (merge current-profile { 
            total-revenue-earned: (+ (get total-revenue-earned current-profile) amount),
            reputation-score: (+ (get reputation-score current-profile) u20)
        }))
        true
    )
)

(define-private (update-user-profile-verification (user principal))
    (let (
        (current-profile (default-to { inventions-registered: u0, inventions-licensed: u0, total-revenue-earned: u0, reputation-score: u0, verification-count: u0 } 
                         (map-get? user-profiles user)))
    )
        (map-set user-profiles user (merge current-profile { 
            verification-count: (+ (get verification-count current-profile) u1),
            reputation-score: (+ (get reputation-score current-profile) u15)
        }))
        true
    )
)

(define-private (update-category-stats (category (string-ascii 50)) (new-inventions uint) (verified-inventions uint) (new-licenses uint))
    (let (
        (current-stats (default-to { total-inventions: u0, verified-inventions: u0, total-licenses: u0 } 
                       (map-get? category-stats category)))
    )
        (map-set category-stats category {
            total-inventions: (+ (get total-inventions current-stats) new-inventions),
            verified-inventions: (+ (get verified-inventions current-stats) verified-inventions),
            total-licenses: (+ (get total-licenses current-stats) new-licenses)
        })
        true
    )
)

(define-read-only (get-invention (invention-id uint))
    (map-get? inventions invention-id)
)

(define-read-only (get-invention-ownership (invention-id uint))
    (map-get? invention-ownership invention-id)
)

(define-read-only (get-invention-license (invention-id uint) (licensee principal))
    (map-get? invention-licenses { invention-id: invention-id, licensee: licensee })
)

(define-read-only (get-invention-verification (invention-id uint) (verifier principal))
    (map-get? invention-verifications { invention-id: invention-id, verifier: verifier })
)

(define-read-only (get-user-profile (user principal))
    (map-get? user-profiles user)
)

(define-read-only (get-category-stats (category (string-ascii 50)))
    (map-get? category-stats category)
)

(define-read-only (is-invention-valid (invention-id uint))
    (match (map-get? inventions invention-id)
        invention (< burn-block-height (get expiry-date invention))
        false
    )
)

(define-read-only (is-license-active (invention-id uint) (licensee principal))
    (match (map-get? invention-licenses { invention-id: invention-id, licensee: licensee })
        license (and (get active license) (< burn-block-height (get expiry-date license)))
        false
    )
)

(define-read-only (get-invention-stats (invention-id uint))
    (match (map-get? inventions invention-id)
        invention (some {
            days-until-expiry: (if (> (get expiry-date invention) burn-block-height)
                                 (/ (- (get expiry-date invention) burn-block-height) u144)
                                 u0),
            license-revenue: (get total-revenue invention),
            active-licenses: (get total-licenses invention),
            is-expired: (>= burn-block-height (get expiry-date invention))
        })
        none
    )
)

(define-read-only (get-registry-stats)
    {
        total-inventions: (var-get invention-counter),
        total-licenses: (var-get license-counter),
        total-fees-collected: (var-get total-registry-fees),
        contract-owner: (var-get contract-owner)
    }
)