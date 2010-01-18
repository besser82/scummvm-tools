/* extract_mohawk - Mohawk file extractor
 * Copyright (C) 2009 The ScummVM project
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * $URL$
 * $Id$
 *
 */

#include "mohawk_file.h"
#include "util.h"
#include "utils/file.h"

#include <assert.h>

// Have a maximum buffer size
#define MAX_BUF_SIZE 16384

static byte *outputBuffer = NULL;

void dumpRawResource(MohawkOutputStream output) {
	assert(outputBuffer);

	// Change the extension to bin
	output.name += ".bin";

	printf ("Extracting \'%s\'...\n", output.name.c_str());

	FILE *outputFile = fopen(output.name.c_str(), "wb");
	if (!outputFile) {
		printf ("Could not open file for output!\n");
		return;
	}

	while (output.stream->pos() < output.stream->size()) {
		uint32 size = output.stream->read(outputBuffer, MAX_BUF_SIZE);
		fwrite(outputBuffer, 1, size, outputFile);
	}

	fflush(outputFile);
	fclose(outputFile);
}

void convertSoundResource(MohawkOutputStream output) {
	printf ("Converting sounds not yet supported. Dumping instead...\n");
	dumpRawResource(output);
}

void convertMovieResource(MohawkOutputStream output) {
	printf ("Converting movies not yet supported. Dumping instead...\n");
	dumpRawResource(output);
}

void convertMIDIResource(MohawkOutputStream output) {
	// Read the Mohawk MIDI header
	assert(output.stream->readUint32BE() == ID_MHWK);
	output.stream->readUint32BE(); // Skip size
	assert(output.stream->readUint32BE() == ID_MIDI);

	uint32 size = output.stream->size() - 12; // Skip MHWK header's size

	byte *midiData = (byte *)malloc(size);

	// Read the MThd Data
	output.stream->read(midiData, 14);

	// Skip the unknown Prg# section
	assert(output.stream->readUint32BE() == ID_PRG);
	output.stream->skip(output.stream->readUint32BE());

	// Read the MTrk Data
	uint32 mtrkSize = output.stream->size() - output.stream->pos();
	output.stream->read(midiData + 14, mtrkSize);

	// Change the extension to midi
	output.name += ".mid";

	printf ("Extracting \'%s\'...\n", output.name.c_str());

	FILE *outputFile = fopen(output.name.c_str(), "wb");
	if (!outputFile) {
		printf ("Could not open file for output!\n");
		free(midiData);
		return;
	}

	// Output the data to the file.
	fwrite(midiData, 1, 14 + mtrkSize, outputFile);
	free(midiData);

	fflush(outputFile);
	fclose(outputFile);
}

void outputMohawkStream(MohawkOutputStream output, bool do_conversion) {
	// File output naming format preserves all archive information...
	char *strBuf = (char *)malloc(256);
	sprintf(strBuf, "%04d_%s_%d", output.index, tag2str(output.tag), output.id);
	if(!output.name.empty())
		sprintf(strBuf+strlen(strBuf), "_%s", output.name.c_str());
	output.name = strBuf;

	if(do_conversion) {
		// Intercept the sound tags
		if (output.tag == ID_TWAV || output.tag == ID_MSND || output.tag == ID_SND) {
			convertSoundResource(output);
			return;
		}

		// Intercept the movie tag (need to change the offsets)
		if (output.tag == ID_TMOV) {
			convertMovieResource(output);
			return;
		}

		// Intercept the MIDI tag (strip out Mohawk header/Prg# stuff)
		if (output.tag == ID_TMID) {
			convertMIDIResource(output);
			return;
		}

		// TODO: Convert other resources? PICT/WDIB/tBMP?
	}

	// Default to dump raw binary...
	dumpRawResource(output);
}

void printUsage(const char *appName) {
	printf("Usage: %s [options] <mohawk archive> [tag id]\n", appName);
	printf("Options : --raw     : Dump Resources as raw binary dump (default)");
	printf("          --convert : Dump Resources as converted files");
}

int main(int argc, char *argv[]) {
	bool do_conversion = false;
	int archive_arg;

	// Parse parameters
	for (archive_arg = 1; archive_arg < argc; archive_arg++) {
		Common::String current = Common::String(argv[archive_arg]);

		if(!current.hasPrefix("--"))
			break;

		// Decode options
		if(current.equals("--raw"))
			do_conversion = false;
		else if(current.equals("--convert"))
			do_conversion = true;
		else {
			printf("Unknown argument : \"%s\"\n", argv[archive_arg]);
			printUsage(argv[0]);
			return 1;
		}
	}

	printf("Debug : argc : %d archive_arg : %d\n", argc, archive_arg);

	if(! (archive_arg == argc     - 1) || // No tag and id
	     (archive_arg == argc - 2 - 1)) { //    tag and id
		printUsage(argv[0]);
		return 1;
	}

	FILE *file = fopen(argv[archive_arg], "rb");
	if (!file) {
		printf ("Could not open \'%s\'\n", argv[1]);
		return 1;
	}

	// Open the file as a Mohawk archive
	MohawkFile *mohawkFile;
	if(Common::String(argv[0]).hasSuffix("old"))
		mohawkFile = new OldMohawkFile();
	else
		mohawkFile = new MohawkFile();
	mohawkFile->open(new Common::File(file));

	// Allocate a buffer for the output
	outputBuffer = (byte *)malloc(MAX_BUF_SIZE);

	if (argc == archive_arg - 2 - 1) {
		uint32 tag = READ_BE_UINT32(argv[archive_arg+1]);
		uint16 id = (uint16)atoi(argv[archive_arg+2]);

		MohawkOutputStream output = mohawkFile->getRawData(tag, id);

		if (output.stream) {
			outputMohawkStream(output, do_conversion);
			delete output.stream;
		} else {
			printf ("Could not find specified data!\n");
		}
	} else {
		MohawkOutputStream output = mohawkFile->getNextFile();
		while (output.stream) {
			outputMohawkStream(output, do_conversion);
			delete output.stream;
			output = mohawkFile->getNextFile();
		}
	}

	printf ("Done!\n");

	free(outputBuffer);

	return 0;
}