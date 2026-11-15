# BZU firmware (2005–2006)

Firmware for the BZU, an electrical safety circuit monitor and breaker by Piotr Stafiniak. It runs on an STMicroelectronics ST6263 microcontroller and is written in ST6 assembly. The comments are in Polish, without diacritics.

Copyright © 2005–2006 Łukasz Stafiniak and Piotr Stafiniak. Published with the agreement of both. No licence has been chosen.

## Files

- `zuc05.asm`: the source, version 05, 1,072 lines.
- `zuc05.lst`: the assembler listing, dated 28 January 2006 (MAST6 macro assembler).
- `zuc05.hex`: the assembled image.

## What it does

This summary follows the header of the source.

- **Measurement.** A direct current is measured on an analog input and its level is shown on a bar of LEDs, one per threshold. The supply voltage is measured on a second analog input.
- **Tripping.** In normal operation the device holds a relay and lights a "working" LED. When the measured level stays at the fault threshold for a set pulse length, it lights the fault LED and releases the relay. Short spikes are filtered out by the pulse length.
- **Hysteresis.** Tripping and release use different thresholds, and the relay pulls in again only after a delay. The supply measurement has its own hysteresis, and after the supply returns the device resumes only after a set number of good measurements.
- **Latch.** As an option, a trip is latched and written to EEPROM, so that it is restored after a loss of power. A reset input clears it when held for a set time. A third LED shows a restored latch, or, without the latch option, that a fault occurred.
- **Test output.** As an option, a signal on the reset pin turns that pin into an output for a set time, for testing the circuit downstream.

## Deciding that the level has changed

The source can be assembled with one of three ways of deciding when the displayed level should change, selected by the constant `TYPDIOD`:

0. A quantile test. The hypothesis is that the level has changed; it is accepted when enough of the last measurements agree. With a window twice the required count this is a median test.
1. Pulse length with a delay before returning to the previous level.
2. Pulse length with voting, where a quorum of measurements must agree.

Other constants at the top of the file switch the third LED, the test output and a debugging build on or off, by conditional assembly. Thresholds and timings are constants in the same place.
