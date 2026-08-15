# Maria Eden Auction Inspection Timeout Fix

NEFARAM loose-script patch for Maria Eden Prostitution `d2026.8.9`.

## Problem

The player auction can stall after a customer completes the visible inspection.
The auction quest starts `MEPAuctionCustomerInspection` at stage 73 and normally
depends entirely on the scene's end fragment to set stage 74. If that fragment
never fires, the customer stands in place and the auction has no recovery path.

The observed Papyrus log selected Okas Sirlo, completed both movement-monitor
steps, and then found the customer and player left in SexLab's `AnimatingFaction`
without a live thread. The auction never logged its stage-74 cleanup callback.

## Fix

The loose `MEP_AuctionQuest.pex` override arms a 90-second watchdog only after an
inspection customer has been selected. Normal scene completion cancels it. If the
quest is still at stage 73 when the timer expires, the patch:

1. stops the inspection scene if it is still marked as playing;
2. allows its normal end fragment one second to run; and
3. invokes the existing stage-74 inspection cleanup only if still necessary.

The patch does not skip healthy inspections, alter bidding, or add a plugin.

## Installation

Install `[NoDelete] Maria Eden Auction Inspection Timeout Fix` after
`MariaEdenProstitution` in the MO2 left pane. It is safe to add to an existing
save. For the cleanest retest, load the save from before entering the auction.

When the fallback is used, Papyrus logs:

`@@ Auction :inspection timed out; forcing normal inspection cleanup`

## Build

Run `Build-And-Deploy.ps1`. A successful build reports `0 error(s), 0 warning(s)`
and deploys only the compiled PEX plus this README. Compile-only stubs remain in
the source project and are never copied to runtime.
