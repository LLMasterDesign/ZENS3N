# Stripe first-offer readiness receipt

Captured: **2026-08-03**  
Status: **Offer not defined; Stripe not activated**  
Owner: **ZENSEN Systems / WrkDsk**

Stripe is useful now only as a test-mode checkout boundary after ZENSEN chooses one concrete offer. This receipt prevents a payment link from becoming a substitute for product definition, fulfillment, refund policy, or public-launch approval.

Reference: [Stripe Payment Links API](https://docs.stripe.com/api/payment-link).

## Current product signal

`Websites/zensensystems/spec/Product.html` currently describes one-time ranges of `$99–$499` and `$499–$999`. Those ranges are market/product direction, not a publishable offer. Atlas must not create a live checkout link from a range or guess the SKU.

## Candidate for owner review — not an active offer

The first bounded test candidate is derived from the existing product table; it is a proposal, not a decision or payment instruction:

| Field | Candidate | Confirmation still required |
| --- | --- | --- |
| Working name | **ZENSEN Ontological Module — Founding Pilot** | Owner may accept or rename it. |
| Price | **$99 USD, one-time** | Owner must approve the exact amount and currency. |
| Promise | One bounded ontological module for one governed-agent experiment, with setup notes and the receipt contract needed to run it. | Exact artifact, scope, and acceptance criteria must be written. |
| Delivery | Founder/manual delivery after a successful test payment. | File format, delivery timeline, and fulfillment owner are not yet defined. |
| Support | `hello@zensensystems.com` | Owner must confirm support coverage and response expectation. |

This candidate uses the published pricing table's lower bound to minimize the first validation commitment. It does not establish that the module is packaged, downloadable, refundable, taxable, or ready for sale.

## Offer contract required before test checkout

- [ ] Exact offer name and one-sentence promise.
- [ ] Exact price and currency.
- [ ] What the buyer receives, and when.
- [ ] Delivery/fulfillment owner and support contact.
- [ ] Refund/cancellation terms.
- [ ] Tax treatment and business identity.
- [ ] Destination/success page and failure path.
- [ ] Owner approves a Stripe test-mode product and Payment Link.
- [ ] Test checkout receipt records the link, test event, and fulfillment response without storing secrets.
- [ ] Live activation remains a separate approval gate.

## Receipt fields

Keep these blank until an offer is approved; never commit API keys or webhook signing secrets.

| Field | Value |
| --- | --- |
| Offer | Not defined |
| Price | Not defined |
| Stripe mode | Not activated |
| Test Payment Link | Not created |
| Test event/receipt | Not run |
| Fulfillment destination | Not defined |
| Approval reference | Not supplied |

## Atlas update command

When the offer is defined, record readiness first. Only use `test-active` after a real test-mode link and event have been verified:

```bash
node deploy/update-launch-board.mjs \
  --provider-track stripe-test-offer \
  --provider-state ready-for-test \
  --evidence STRIPE-OFFER-READINESS.md \
  --note 'Offer contract is complete; test-mode checkout awaits owner activation.'
```

```bash
node deploy/update-launch-board.mjs \
  --provider-track stripe-test-offer \
  --provider-state test-active \
  --evidence STRIPE-OFFER-READINESS.md \
  --url 'https://buy.stripe.com/test_approved_link' \
  --approval-ref 'approved-test-offer-YYYY-MM-DD' \
  --note 'Test checkout and fulfillment event verified.'
```
