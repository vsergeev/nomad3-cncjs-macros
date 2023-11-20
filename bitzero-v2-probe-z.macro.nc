; BitZero V2 Probe Z Macro
;
; Instructions
;   Run with tool within 20mm of top of probe surface.
;
; Based on
;    https://github.com/cncjs/CNCjs-Macros/blob/master/C3D_3axis_probe
;
; Change Log
;   * 11/19/2023
;       * Initial release.
;
; https://github.com/vsergeev/nomad3-cncjs-macros

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%PROBE_THICKNESS = 15.5 ; Probe overall thickness, mm

%PROBE_DISTANCE = 20 ; mm
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
; Probe Z
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

G91 ; Incremental positioning

; Probe fast
G38.2 Z-[PROBE_DISTANCE] F[PROBE_FAST_FEEDRATE]
G1 Z2 F[TRAVEL_FEEDRATE]

; Probe slow
G38.2 Z-5 F[PROBE_SLOW_FEEDRATE]
G4 P0.1

; Offset WCS Z by probe thickness
G10 L20 Z[PROBE_THICKNESS]
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
