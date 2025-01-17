/*
 * PSP Software Development Kit - https://github.com/pspdev
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * psploadcore.h - Interface to LoadCoreForKernel.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 */

#ifndef PSPLOADCORE_H
#define PSPLOADCORE_H

#include <pspkerneltypes.h>

/** @defgroup LoadCore Interface to the LoadCoreForKernel library.
 */

#ifdef __cplusplus
extern "C" {
#endif

/** @addtogroup LoadCore Interface to the LoadCoreForKernel library. */
/**@{*/

/** Describes a module.  This structure could change in future firmware revisions. */
typedef struct SceModule {
	struct SceModule *	next;
	u16			attribute;
	u8			version[2];
	char			modname[27];
	char			terminal;
	u32			unknown1;
	u32			unknown2;
	SceUID			modid;
	u32			unknown3[4];
	void *			ent_top;
	u32			ent_size;
	void *			stub_top;
	u32			stub_size;
	u32			unknown4[4];
	u32			entry_addr;
	u32			gp_value;
	u32			text_addr;
	u32			text_size;
	u32			data_size;
	u32			bss_size;
	u32			nsegment;
	u32			segmentaddr[4];
	u32			segmentsize[4];
} SceModule;

// For 1.50+

typedef struct SceModule2  {
	struct SceModule2 *	next; // 0
	u16			attribute; // 4
	u8			version[2]; // 6
	char			modname[27]; // 8
	char			terminal; // 0x23
	char			mod_state;	// 0x24
	char			unk1;    // 0x25
	char			unk2[2]; // 0x26
	u32			unk3;	// 0x28
	SceUID			modid; // 0x2C
	u32			unk4; // 0x30
	SceUID			mem_id; // 0x34
	u32			mpid_text;	// 0x38
	u32			mpid_data; // 0x3C
	void *			ent_top; // 0x40
	u32			ent_size; // 0x44
	void *			stub_top; // 0x48
	u32			stub_size; // 0x4C
	u32			entry_addr_; // 0x50
	u32			unk5[4]; // 0x54
	u32			entry_addr; // 0x64
	u32			gp_value; // 0x68
	u32			text_addr; // 0x6C
	u32			text_size; // 0x70
	u32			data_size;	// 0x74
	u32			bss_size; // 0x78
	u32			nsegment; // 0x7C
	u32			segmentaddr[4]; // 0x80
	u32			segmentsize[4]; // 0x90
} SceModule2;

/** Defines a library and its exported functions and variables.  Use the len
    member to determine the real size of the table (size = len * 4). */
typedef struct SceLibraryEntryTable {
	/**The library's name. */
	const char *		libname;
	/** Library version. */
	unsigned char		version[2];
	/** Library attributes. */
	unsigned short		attribute;
	/** Length of this entry table in 32-bit WORDs. */
	unsigned char		len;
	/** The number of variables exported by the library. */
	unsigned char		vstubcount;
	/** The number of functions exported by the library. */
	unsigned short		stubcount;
	/** Pointer to the entry table; an array of NIDs followed by
	    pointers to functions and variables. */
	void *				entrytable;
} SceLibraryEntryTable;

/** Specifies a library and a set of imports from that library.  Use the len
    member to determine the real size of the table (size = len * 4). */
typedef struct SceLibraryStubTable {
	/* The name of the library we're importing from. */
	const char *		libname;
	/** Minimum required version of the library we want to import. */
	unsigned char		version[2];
	/* Import attributes. */
	unsigned short		attribute;
	/** Length of this stub table in 32-bit WORDs. */
	unsigned char		len;
	/** The number of variables imported from the library. */
	unsigned char		vstubcount;
	/** The number of functions imported from the library. */
	unsigned short		stubcount;
	/** Pointer to an array of NIDs. */
	u32 *		nidtable;
	/** Pointer to the imported function stubs. */
	void *				stubtable;
	/** Pointer to the imported variable stubs. */
	void *				vstubtable;
} SceLibraryStubTable;


/**
 * Find a module by it's name.
 *
 * @param modname - The name of the module.
 *
 * @return Pointer to the ::SceModule structure if found, otherwise NULL.
 */
SceModule2 *sceKernelFindModuleByName(const char *modname);

/**
 * Find a module from an address.
 *
 * @param addr - Address somewhere within the module.
 *
 * @return Pointer to the ::SceModule structure if found, otherwise NULL.
 */
SceModule2 *sceKernelFindModuleByAddress(u32 addr);

/**
 * Find a module by it's UID.
 *
 * @param modid - The UID of the module.
 *
 * @return Pointer to the ::SceModule structure if found, otherwise NULL.
 */
SceModule2 *sceKernelFindModuleByUID(SceUID modid);

/**
 * Return the count of loaded modules.
 *
 * @return The count of loaded modules.
 */
int sceKernelModuleCount(void);

/**
 * Invalidate the CPU's instruction cache.
 */
void sceKernelIcacheClearAll(void);

/**@}*/

#ifdef __cplusplus
}
#endif

#endif /* PSPLOADCORE_H */
