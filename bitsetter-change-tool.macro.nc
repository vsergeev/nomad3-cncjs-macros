; BitSetter Change Tool Macro
;
; Instructions
;   Run once prior to job start (before or after zeroing WCS Z, doesn't matter).
;   Run on every tool change to adjust WCS Z with tool offset.
;   Use "BitSetter Clear Tool Reference" macro to clear stored tool reference.
;
; Derived from
;    https://github.com/cncjs/cncjs/wiki/Tool-Change
;    https://github.com/cncjs/CNCjs-Macros/tree/master/C3D_BitSetter
;    https://community.carbide3d.com/t/gsender-from-sienci-labs-cncjs-based-sender/35937/61
;
; Change Log
;   * 11/19/2023
;       * Initial release.
;
; https://github.com/vsergeev/nomad3-cncjs-macros

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Configured for Carbide 3D Nomad 3
%SAFE_HEIGHT_Z = -5 ; MCS
%TOOL_CHANGE_X = -125 ; MCS
%TOOL_CHANGE_Y = -110 ; MCS
%TOOL_PROBE_X = -5 ; MCS
%TOOL_PROBE_Y = -3 ; MCS
%TOOL_PROBE_Z = -75 ; MCS

%TOOL_PROBE_DISTANCE = 20 ; mm
%TOOL_PROBE_FAST_FEEDRATE = 100 ; mm/min
%TOOL_PROBE_SLOW_FEEDRATE = 50 ; mm/min
%TRAVEL_FEEDRATE = 5000 ; mm/min

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Save modal state
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%wait

%WCS = modal.wcs
%PLANE = modal.plane
%UNITS = modal.units
%DISTANCE = modal.distance
%FEEDRATE = modal.feedrate
%SPINDLE = modal.spindle
%COOLANT = modal.coolant

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Save current work position
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%X0 = posx, Y0 = posy, Z0 = posz

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%global.state = global.state || {} ; Initialize global.state object

M5 ; Stop spindle
G21 ; Units metric

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Go to tool change location
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

G90 ; Absolute positioning
G53 G1 Z[SAFE_HEIGHT_Z] F[TRAVEL_FEEDRATE]
G53 G1 X[TOOL_CHANGE_X] Y[TOOL_CHANGE_Y] F[TRAVEL_FEEDRATE]

%wait

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Change tool
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Pause for manual tool change
M0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Go to probe location
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

G90 ; Absolute positioning
G53 G1 X[TOOL_PROBE_X] Y[TOOL_PROBE_Y] F[TRAVEL_FEEDRATE]
G53 G1 Z[TOOL_PROBE_Z] F800

G4 P0.1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Probe
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

G91 ; Incremental positioning

; Fast probe
G38.2 Z-[TOOL_PROBE_DISTANCE] F[TOOL_PROBE_FAST_FEEDRATE]
G0 Z2

; Slow probe
G38.2 Z-5 F[TOOL_PROBE_SLOW_FEEDRATE]
G4 P0.1

; Compute tool offset from reference
%TOOL_OFFSET = (mposz - global.state.TOOL_REFERENCE_Z) || 0
(Tool Offset: [TOOL_OFFSET])

; Save tool reference
%global.state.TOOL_REFERENCE_Z = mposz
(New Tool Reference: [global.state.TOOL_REFERENCE_Z])

; Offset WCS by tool offset
G10 L20 Z[posz - TOOL_OFFSET]

G4 P0.1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Go back to saved work position at safe height
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

G90 ; Absolute positioning
G53 G1 Z[SAFE_HEIGHT_Z] F[TRAVEL_FEEDRATE]
G1 X[X0] Y[Y0] F[TRAVEL_FEEDRATE]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Restore modal state
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%wait

[WCS] [PLANE] [UNITS] [DISTANCE] [FEEDRATE] [SPINDLE] [COOLANT]
