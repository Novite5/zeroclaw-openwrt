# Upstream Sync Strategy

## Branch Structure

```
upstream/zeroclaw-labs/zeroclaw (master)
         ↓ (auto-sync every 6 hours)
origin/build-for-openwrt (your working branch)
```

## How It Works

### 1. Automatic Sync (Every 6 Hours)

The `sync-upstream.yml` workflow:
1. Fetches latest changes from `zeroclaw-labs/zeroclaw/master`
2. Preserves OpenWrt build files:
   - `.github/workflows/build-openwrt-ipk.yml`
   - `Makefile`
   - `files/` directory
3. Pushes to `build-for-openwrt` branch
4. Creates a PR if there are conflicts

### 2. Manual Sync

```bash
# Trigger via GitHub CLI
gh workflow run sync-upstream.yml

# Or with specific branch
gh workflow run sync-upstream.yml --field sync_branch=master
```

### 3. Release Auto-Build

When upstream releases a new version:
1. `release` event triggers `build-openwrt-ipk.yml`
2. Makefile is updated with new version
3. IPK is built and published as GitHub Release

## Protected Files

These files are **never** overwritten by upstream sync:

| File | Purpose |
|------|---------|
| `.github/workflows/build-openwrt-ipk.yml` | OpenWrt IPK build workflow |
| `.github/workflows/sync-upstream.yml` | Upstream sync workflow |
| `Makefile` | OpenWrt package definition |
| `files/*` | OpenWrt config and init scripts |

## Conflict Resolution

If upstream modifies a protected file:

1. **Automatic**: Sync workflow preserves our version
2. **Manual Review**: A PR is created for conflict resolution
3. **Alert**: Check Actions tab for sync results

## Workflow Summary

```
┌─────────────────────────────────────────────────────────────┐
│  Upstream Release (zeroclaw-labs/zeroclaw)                  │
└─────────────────────┬───────────────────────────────────────┘
                      │
         ┌────────────┴────────────┐
         │                         │
         ▼                         ▼
┌─────────────────┐      ┌─────────────────┐
│  Release Event  │      │  Sync Schedule  │
│  (immediate)    │      │  (every 6h)     │
└────────┬────────┘      └────────┬────────┘
         │                        │
         ▼                        ▼
┌─────────────────────────────────────────────────────────────┐
│           build-for-openwrt Branch                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  1. Fetch upstream changes                          │   │
│  │  2. Preserve OpenWrt files                          │   │
│  │  3. Update Makefile version (if release)            │   │
│  │  4. Build IPK package                               │   │
│  │  5. Create GitHub Release                           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Sync Failed

Check the [Actions tab](../../actions) for sync workflow logs.

### Manual Sync Required

```bash
# Fetch upstream
git remote add upstream https://github.com/zeroclaw-labs/zeroclaw.git
git fetch upstream

# Merge upstream changes
git checkout build-for-openwrt
git merge upstream/master --no-commit

# Restore our files
git checkout HEAD -- .github/workflows/ Makefile files/

# Commit
git commit -m "chore: sync upstream, preserve build files"
git push
```

### Disable Auto-Sync

Delete or rename `.github/workflows/sync-upstream.yml`
