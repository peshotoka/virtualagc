### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	MAIN.agc
# Purpose:	Top-level source file for Comanche 67 (Colossus 2C),
#		the one-and-only software release for the Apollo Guidance 
#		Computer (AGC) of Apollo 12's command module.  It 
#		provides the overall structure for the program by 
#		linking together all of the individual log sections.  
# Contact:	Ron Burkey <info@sandroid.org>.
# Website:	www.ibiblio.org/apollo.
# Mod history:	2020-12-25 RSB	Adapted from Comanche055/MAIN.agc.
#				Aside from the removal of a bunch of my
#				own comments, I've also removed the 
#				CONTRACT AND APPROVALS log section;
#				there's no reason to believe that
#				any mission other than Apollo 11 had one.
#
# Note that this file is provided as a convenience for use with the modern
# AGC assembler, and was not present in contemporary AGC source code.
# Hence while this file differs in various ways from the baseline Comanche 55
# equivalent file, no annotations have been added here to justify any of
# those differences.

$ASSEMBLY_AND_OPERATION_INFORMATION.agc
$TAGS_FOR_RELATIVE_SETLOC_AND_BLANK_BANK_CARDS.agc

# COMERASE
$ERASABLE_ASSIGNMENTS.agc

# COMAID
$INTERRUPT_LEAD_INS.agc
$T4RUPT_PROGRAM.agc
$DOWNLINK_LISTS.agc
$FRESH_START_AND_RESTART.agc
$RESTART_TABLES.agc
$SXTMARK.agc
$EXTENDED_VERBS.agc
$PINBALL_NOUN_TABLES.agc
$CSM_GEOMETRY.agc
$IMU_COMPENSATION_PACKAGE.agc
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc
$R60,R62.agc
$ANGLFIND.agc
$GIMBAL_LOCK_AVOIDANCE.agc
$KALCMANU_STEERING.agc
$SYSTEM_TEST_STANDARD_LEAD_INS.agc
$IMU_CALIBRATION_AND_ALIGNMENT.agc

# COMEKISS
$GROUND_TRACKING_DETERMINATION_PROGRAM_-_P21.agc
$P34-P35,_P74-P75.agc
$R31.agc
$P76.agc
$R30.agc
$STABLE_ORBIT_-_P38-P39.agc

# TROUBLE
$P11.agc
$TPI_SEARCH.agc
$P20-P25.agc
$P30,P37.agc
$P32-P33,_P72-P73.agc
$P40-P47.agc
$P51-P53.agc
$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc
$P61-P67.agc
$SERVICER207.agc
$ENTRY_LEXICON.agc
$REENTRY_CONTROL.agc
$CM_BODY_ATTITUDE.agc
$P37,P70.agc
$S-BAND_ANTENNA_FOR_CM.agc
$LUNAR_LANDMARK_SELECTION_FOR_CM.agc

# TVCDAPS
$TVCINITIALIZE.agc
$TVCEXECUTIVE.agc
$TVCMASSPROP.agc
$TVCRESTARTS.agc
$TVCDAPS.agc
$TVCSTROKETEST.agc
$TVCROLLDAP.agc
$MYSUBS.agc
$RCS-CSM_DIGITAL_AUTOPILOT.agc
$AUTOMATIC_MANEUVERS.agc
$RCS-CSM_DAP_EXECUTIVE_PROGRAMS.agc
$JET_SELECTION_LOGIC.agc
$CM_ENTRY_DIGITAL_AUTOPILOT.agc

# CHIEFTAN
$DOWN-TELEMETRY_PROGRAM.agc
$INTER-BANK_COMMUNICATION.agc
$INTERPRETER.agc
$FIXED-FIXED_CONSTANT_POOL.agc
$INTERPRETIVE_CONSTANTS.agc
$SINGLE_PRECISION_SUBROUTINES.agc
$EXECUTIVE.agc
$WAITLIST.agc
$LATITUDE_LONGITUDE_SUBROUTINES.agc
$PLANETARY_INERTIAL_ORIENTATION.agc
$MEASUREMENT_INCORPORATION.agc
$CONIC_SUBROUTINES.agc
$INTEGRATION_INITIALIZATION.agc
$ORBITAL_INTEGRATION.agc
$INFLIGHT_ALIGNMENT_ROUTINES.agc
$POWERED_FLIGHT_SUBROUTINES.agc
$TIME_OF_FREE_FALL.agc
$STAR_TABLES.agc
$AGC_BLOCK_TWO_SELF-CHECK.agc
$PHASE_TABLE_MAINTENANCE.agc
$RESTARTS_ROUTINE.agc
$IMU_MODE_SWITCHING_ROUTINES.agc
$KEYRUPT,_UPRUPT.agc
$DISPLAY_INTERFACE_ROUTINES.agc
$SERVICE_ROUTINES.agc
$ALARM_AND_ABORT.agc
$UPDATE_PROGRAM.agc
$RTB_OP_CODES.agc






