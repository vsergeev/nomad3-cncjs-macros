; BitZero V2 Probe XY Macro
;
; Instructions
;   Run with tool located inside probing bore.
;
; Based on
;   https://github.com/cncjs/CNCjs-Macros/blob/master/C3D_3axis_probe
;
; Change Log
;   * 11/19/2023
;       * Initial release.
;
; https://github.com/vsergeev/nomad3-cncjs-macros

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%PROBE_BORE_DIAMETER = 15 ; Bore diameter, mm
%PROBE_X_OFFSET = 0 ; Bore offset correction from actual X0, mm
%PROBE_Y_OFFSET = 0 ; Bore offset correction from actual Y0, mm

%PROBE_FEEDRATE = 100 ; mm/min
%TRAVEL_FEEDRATE = 300 ; mm/min
%SAFE_HEIGHT = 15 ; mm

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
; Setup
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

M5 ; Stop spindle
G21 ; Units metric

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Probe X
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

G91 ; Incremental positioning

; Probe left
G38.2 X-[PROBE_BORE_DIAMETER] F[PROBE_FEEDRATE]
G4 P0.1
%X1 = Number(posx)

; Retract X
G1 X1 F[TRAVEL_FEEDRATE]

; Probe right
G38.2 X[PROBE_BORE_DIAMETER] F[PROBE_FEEDRATE]
G4 P0.1
%X2 = Number(posx)

; Go to X center
G90 ; Absolute positioning
G1 X[(X1 + X2) / 2] F[TRAVEL_FEEDRATE]
G4 P0.1

; Set WCS X
G10 L20 X[PROBE_X_OFFSET]
G4 P0.1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Probe Y
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

G91 ; Incremental positioning

; Probe top
G38.2 Y[PROBE_BORE_DIAMETER] F[PROBE_FEEDRATE]
G4 P0.1
%Y1 = Number(posy)

; Retract Y
G1 Y-1 F[TRAVEL_FEEDRATE]

; Probe bottom
G38.2 Y-[PROBE_BORE_DIAMETER] F[PROBE_FEEDRATE]
G4 P0.1
%Y2 = Number(posy)

; Go to Y center
G90 ; Absolute positioning
G1 Y[(Y1 + Y2) / 2] F[TRAVEL_FEEDRATE]
G4 P0.1

; Set WCS Y
G10 L20 Y[PROBE_Y_OFFSET]
G4 P0.1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Go to work zero
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Retract Z
G91 ; Incremental positioning
G1 Z[SAFE_HEIGHT] F[TRAVEL_FEEDRATE]

; Go to work zero (no travel if probe offsets are 0)
G90 ; Absolute positioning
G1 X0 Y0 F[TRAVEL_FEEDRATE]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Restore modal state
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%wait

[WCS] [PLANE] [UNITS] [DISTANCE] [FEEDRATE] [SPINDLE] [COOLANT]
