# Cloud Functions Organization

## Structure

The Cloud Functions are now organized by feature, following the same pattern as the frontend architecture:

```
functions/
├── src/
│   ├── index.ts              # Main entry point, exports all functions
│   └── admin/                # Admin-related functions
│       └── analytics.ts      # Analytics & data maintenance functions
```

## Admin Analytics Functions

### `backfillUserTimestamps`

**Type:** HTTP Request Function  
**Path:** `/adminAnalytics-backfillUserTimestamps`  
**Security:** Requires `BACKFILL_KEY` parameter

Backfills missing `created_at` and `updated_at` timestamps in the `users` collection.

#### Usage

**Dry Run (Preview):**
```
https://us-central1-turo-31805.cloudfunctions.net/adminAnalytics-backfillUserTimestamps?key=YOUR_KEY&dryRun=true
```

**Execute:**
```
https://us-central1-turo-31805.cloudfunctions.net/adminAnalytics-backfillUserTimestamps?key=YOUR_KEY
```

#### Parameters
- `key` (required): Admin key matching `BACKFILL_KEY` environment variable
- `dryRun` (optional): Set to `true` to preview without writing

#### Response
```json
{
  "dryRun": false,
  "scanned": 123,
  "toUpdate": 27,
  "createdAtSet": 20,
  "updatedAtSet": 7,
  "message": "Backfill completed"
}
```

## How Functions are Exported

Functions are exported using feature namespaces:

```typescript
// In index.ts
export * as adminAnalytics from "./admin/analytics";
```

This creates function names like:
- `adminAnalytics-backfillUserTimestamps`
- `adminAnalytics-<future-function-name>`

## Adding New Functions

### To add a new admin function:

1. Add it to `src/admin/analytics.ts` (or create a new file in `admin/`)
2. Export it from the file
3. The function is automatically exported via the namespace in `index.ts`

### To add a new feature category:

1. Create a new folder: `src/<feature>/`
2. Create function files inside it
3. Export in `index.ts`: `export * as <feature> from "./<feature>/<file>";`

## Environment Variables

Set these in Firebase Functions config or `.env`:

- `EMAIL` - Email provider for OTP
- `PASSWORD` - Email password
- `BACKFILL_KEY` - Admin key for maintenance functions (rotate after use)

## Deployment

```bash
cd functions
npm run build
firebase deploy --only functions
```

Or deploy specific function groups:
```bash
firebase deploy --only functions:adminAnalytics
```

## Safety Notes

- The `backfillUserTimestamps` function is designed to run once
- Always do a dry run first
- Rotate the `BACKFILL_KEY` after running
- Keep team functions (OTP, profile saves) in `index.ts` until they're moved to their respective feature folders
