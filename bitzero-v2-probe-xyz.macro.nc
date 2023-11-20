; BitZero V2 Probe XYZ Macro
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

%PROBE_INSET_THICKNESS = 13 ; Probe inset thickness, mm
%PROBE_BORE_DIAMETER = 15 ; Bore diameter, mm
%PROBE_X_OFFSET = 0 ; Bore offset correction from actual X0, mm
%PROBE_Y_OFFSET = 0 ; Bore offset correction from actual Y0, mm

%PROBE_FAST_FEEDRATE = 100 ; mm/min
%PROBE_SLOW_FEEDRATE = 50 ; mm/min
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
G38.2 X-[PROBE_BORE_DIAMETER] F[PROBE_FAST_FEEDRATE]
G4 P0.1
%X1 = Number(posx)

; Retract X
G1 X1 F[TRAVEL_FEEDRATE]

; Probe right
G38.2 X[PROBE_BORE_DIAMETER] F[PROBE_FAST_FEEDRATE]
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
G38.2 Y[PROBE_BORE_DIAMETER] F[PROBE_FAST_FEEDRATE]
G4 P0.1
%Y1 = Number(posy)

; Retract Y
G1 Y-1 F[TRAVEL_FEEDRATE]

; Probe bottom
G38.2 Y-[PROBE_BORE_DIAMETER] F[PROBE_FAST_FEEDRATE]
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
; Probe Z
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

G91 ; Incremental positioning

; Retract Z
G1 Z[PROBE_INSET_THICKNESS] F[TRAVEL_FEEDRATE]
; Travel diagonally to over probe top plate
G1 X[PROBE_BORE_DIAMETER] Y[PROBE_BORE_DIAMETER] F[TRAVEL_FEEDRATE]

; Probe fast
G38.2 Z-[PROBE_INSET_THICKNESS] F[PROBE_FAST_FEEDRATE]
G1 Z2 F[TRAVEL_FEEDRATE]

; Probe slow
G38.2 Z-5 F[PROBE_SLOW_FEEDRATE]
G4 P0.1

; Offset WCS Z by probe thickness
G10 L20 Z[PROBE_INSET_THICKNESS]
G4 P0.1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Retract Z
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Retract Z
G91 ; Incremental positioning
G1 Z[SAFE_HEIGHT] F[TRAVEL_FEEDRATE]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Restore modal state
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%wait

[WCS] [PLANE] [UNITS] [DISTANCE] [FEEDRATE] [SPINDLE] [COOLANT]
