// Component type defines
#define COMPONENT_HEAD 1
#define COMPONENT_BODY 2
#define COMPONENT_ARM  3
#define COMPONENT_LEGS 4

// Component weight
#define WEIGHT_LIGHT 1
#define WEIGHT_MEDIUM 2
#define WEIGHT_HEAVY 3

// Bitflag for equipment class / circuit board classes
#define CLASS_COMBAT		0x1
#define CLASS_MEDICAL		0x2
#define CLASS_ENGINEERING	0x4
#define CLASS_EXPERIMENTAL	0x8
#define CLASS_UTILITY		0x10
#define CLASS_GENERAL		0x20
//Next is 0x40, then 0x80, then 0x100, etc

// Equipment class checks
#define CHECK_ANY		1	// One of the classes defined must be unlocked to mount this
#define CHECK_ALL		2	// All classes must be unlocked
#define CHECK_CUSTOM	3	// For all your snowflake needs