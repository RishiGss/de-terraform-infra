# Bootstrap

This directory exists to solve a chicken-and-egg problem, and it is deliberately **not** structured like `environments/dev` or `environments/prod`.
Read this before touching anything in here.

## Why this exists as a separate thing

Everything in `environments/` assumes two things already exist:
1. A GCS bucket to hold remote Terraform state
2. A service account that Terraform can impersonate to act on GCP

Neither of those can be created by the config that depends on them — you cannot store state in a bucket that doesn't exist yet, and you cannot impersonate a service account that hasn't been created yet.

So this folder creates exactly those two things, once, using **local state** and **your own user identity** (via ADC) — not the provisioner SA, because the SA doesn't exist until this config creates it.

## What lives here

- `google_service_account` — `dev-tf-provisioner-sa`, the identity every `environments/dev/*` config impersonates from here on. 
The `deletion_policy = "PREVENT"` on the SA — this identity should not be deletable by a stray `terraform destroy` run against this folder
- `google_project_iam_member` (x2) — `roles/storage.admin` and `roles/bigquery.admin`, granted to that SA
- `google_service_account_iam_member` — grants your own user `roles/iam.serviceAccountTokenCreator` on that SA, which is what makes impersonation possible
- `google_storage_bucket` — creates the GCS bucket that acts as the remote backend for Terraform in dev project

## What does NOT belong here

Nothing that `environments/dev` or `environments/prod` will manage day-to-day — no data buckets, no BQ datasets, no Dataproc, no networking. 
Those go through the normal module + environment flow once this bootstrap has run. 
If you find yourself adding an ongoing, frequently-changed resource to this folder, that's a sign it's in the wrong place.

## How to run this

1. Confirm you're authenticated as your own user (`gcloud auth application-default login` should already be set from Day 1).
2. `terraform init` — local state, no backend block, this is deliberate.
3. `terraform plan` — confirm the exact resource count before proceeding. Any surprise here means stop and investigate, not apply.
4. `terraform apply` — this runs as your user identity. This is the one and only place in the whole repo where that's correct instead of a mistake.
5. Verify impersonation works:
   `gcloud auth print-access-token --impersonate-service-account=<sa-email>`
6. Confirm no JSON key was ever created:
   `find ~ -iname "*tf-provisioner*"` should show nothing but this folder's own state file.

## Should you run this again?

Almost never. This is a one-time setup per environment. 
You will run it a second time when `prod` is bootstrapped in W17 — same steps, `prd_project` instead of `dev_project`, a separate state bucket, a separate SA (`prd-tf-provisioner-sa`).

If you're re-running this against `dev` because something broke, stop and figure out *why* before re-applying — a broken bootstrap usually means something was changed by hand outside Terraform (drift), not that this config is wrong.

## State

This folder's `terraform.tfstate` is local and **gitignored**. It is not backed up to GCS, deliberately — bootstrapping the backend is the one job this config exists to do, so it can't depend on the backend
it's creating. Treat this state file as precious: if you lose it, recovery means `terraform import`-ing the SA and bucket back into a fresh state, not a quick fix.