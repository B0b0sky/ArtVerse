;; ArtVerse - A decentralized art marketplace and exhibition platform
;; This contract allows artists to mint digital art and galleries to curate exhibitions

(define-non-fungible-token digital-artwork uint)

;; Data storage
(define-map artwork-details uint {title: (string-ascii 64), description: (string-ascii 256), media-uri: (string-utf8 256)})
(define-map artwork-properties uint (list 20 {property: (string-ascii 32), value: (string-ascii 64)}))
(define-map gallery-registry principal {name: (string-ascii 64), active: bool})
(define-map gallery-artwork-curation {gallery-id: principal, artwork-id: uint} {featured: bool, prominence-score: uint})
(define-map artwork-ownership uint principal)

;; Error codes
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_GALLERY_NOT_REGISTERED (err u101))
(define-constant ERR_ARTWORK_NOT_FOUND (err u102))
(define-constant ERR_ALREADY_REGISTERED (err u103))
(define-constant ERR_INVALID_PARAMS (err u104))
(define-constant ERR_NOT_OWNER (err u105))
(define-constant ERR_INVALID_PRINCIPAL (err u106))
(define-constant ERR_EMPTY_STRING (err u107))
(define-constant ERR_INVALID_VALUE (err u108))

;; Constants
(define-constant ZERO_ADDRESS 'SP000000000000000000002Q6VF78)
(define-constant MAX_PROMINENCE_SCORE u1000)

;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; Admin functions
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    ;; Validate new owner is not zero address
    (asserts! (not (is-eq new-owner ZERO_ADDRESS)) ERR_INVALID_PRINCIPAL)
    (ok (var-set contract-owner new-owner))))

;; Gallery registration
(define-public (register-gallery (gallery-name (string-ascii 64)))
  (begin
    ;; Validate gallery name is not empty
    (asserts! (> (len gallery-name) u0) ERR_EMPTY_STRING)
    (let ((gallery-exists (default-to {name: "", active: false} (map-get? gallery-registry tx-sender))))
      (asserts! (not (get active gallery-exists)) ERR_ALREADY_REGISTERED)
      (ok (map-set gallery-registry tx-sender {name: gallery-name, active: true})))))

(define-public (deactivate-gallery)
  (let ((gallery-exists (default-to {name: "", active: false} (map-get? gallery-registry tx-sender))))
    (asserts! (get active gallery-exists) ERR_GALLERY_NOT_REGISTERED)
    (ok (map-set gallery-registry tx-sender 
      {name: (get name gallery-exists), active: false}))))

;; NFT functions
(define-public (mint-artwork 
    (recipient principal) 
    (artwork-id uint) 
    (title (string-ascii 64)) 
    (description (string-ascii 256)) 
    (media-uri (string-utf8 256)))
  (begin
    (asserts! (or (is-eq tx-sender (var-get contract-owner)) 
                 (is-some (map-get? gallery-registry tx-sender))) ERR_NOT_AUTHORIZED)
    (asserts! (is-none (nft-get-owner? digital-artwork artwork-id)) ERR_ALREADY_REGISTERED)
    
    ;; Validate recipient is not zero address
    (asserts! (not (is-eq recipient ZERO_ADDRESS)) ERR_INVALID_PRINCIPAL)
    ;; Validate strings are not empty
    (asserts! (> (len title) u0) ERR_EMPTY_STRING)
    (asserts! (> (len description) u0) ERR_EMPTY_STRING)
    (asserts! (> (len media-uri) u0) ERR_EMPTY_STRING)
    
    (try! (nft-mint? digital-artwork artwork-id recipient))
    (map-set artwork-details artwork-id {title: title, description: description, media-uri: media-uri})
    (map-set artwork-ownership artwork-id recipient)
    (ok artwork-id)))

(define-public (transfer-artwork (artwork-id uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? digital-artwork artwork-id) ERR_ARTWORK_NOT_FOUND)) ERR_NOT_OWNER)
    ;; Validate recipient is not zero address
    (asserts! (not (is-eq recipient ZERO_ADDRESS)) ERR_INVALID_PRINCIPAL)
    (try! (nft-transfer? digital-artwork artwork-id tx-sender recipient))
    (map-set artwork-ownership artwork-id recipient)
    (ok true)))

;; Gallery curation functions
(define-public (set-artwork-curation (artwork-id uint) (prominence-score uint) (featured bool))
  (begin
    (asserts! (is-some (map-get? gallery-registry tx-sender)) ERR_GALLERY_NOT_REGISTERED)
    (asserts! (is-some (nft-get-owner? digital-artwork artwork-id)) ERR_ARTWORK_NOT_FOUND)
    ;; Validate prominence score is within acceptable range
    (asserts! (<= prominence-score MAX_PROMINENCE_SCORE) ERR_INVALID_VALUE)
    (ok (map-set gallery-artwork-curation {gallery-id: tx-sender, artwork-id: artwork-id} 
                {featured: featured, prominence-score: prominence-score}))))

;; Helper function to validate properties
(define-private (validate-property (prop {property: (string-ascii 32), value: (string-ascii 64)}))
  (and (> (len (get property prop)) u0) (> (len (get value prop)) u0)))

(define-private (validate-properties (props (list 20 {property: (string-ascii 32), value: (string-ascii 64)})))
  (let ((props-len (len props)))
    (and 
      (> props-len u0)
      (is-eq props-len (len (filter validate-property props))))))

;; Artwork property functions
(define-public (set-artwork-properties (artwork-id uint) (properties (list 20 {property: (string-ascii 32), value: (string-ascii 64)})))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    (asserts! (is-some (nft-get-owner? digital-artwork artwork-id)) ERR_ARTWORK_NOT_FOUND)
    ;; Validate properties
    (asserts! (validate-properties properties) ERR_INVALID_VALUE)
    (ok (map-set artwork-properties artwork-id properties))))

;; Read-only functions
(define-read-only (get-artwork-details (artwork-id uint))
  (map-get? artwork-details artwork-id))

(define-read-only (get-artwork-properties (artwork-id uint))
  (map-get? artwork-properties artwork-id))

(define-read-only (get-artwork-curation (gallery-id principal) (artwork-id uint))
  (map-get? gallery-artwork-curation {gallery-id: gallery-id, artwork-id: artwork-id}))

(define-read-only (get-gallery-info (gallery-id principal))
  (map-get? gallery-registry gallery-id))

(define-read-only (get-artwork-owner (artwork-id uint))
  (nft-get-owner? digital-artwork artwork-id))

(define-read-only (is-gallery-active (gallery-id principal))
  (match (map-get? gallery-registry gallery-id)
    gallery-data (get active gallery-data)
    false))