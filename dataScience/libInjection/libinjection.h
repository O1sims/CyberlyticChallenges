/**
 * Copyright 2012-2016 Nick Galbreath
 * nickg@client9.com
 * BSD License -- see COPYING.txt for details
 *
 * https://libinjection.client9.com/
 *
 */

#ifndef LIBINJECTION_H
#define LIBINJECTION_H

#ifdef __cplusplus
# define LIBINJECTION_BEGIN_DECLS    extern "C" {
# define LIBINJECTION_END_DECLS      }
#else
# define LIBINJECTION_BEGIN_DECLS
# define LIBINJECTION_END_DECLS
#endif

LIBINJECTION_BEGIN_DECLS

/*
 * Pull in size_t
 */
#include <string.h>

/*
 * Version info.
 *
 * This is moved into a function to allow SWIG and other auto-generated
 * binding to not be modified during minor release changes.  We change
 * change the version number in the c source file, and not regenerated
 * the binding
 *
 * See python's normalized version
 * http://www.python.org/dev/peps/pep-0386/#normalizedversion
 */
const char* libinjection_version(void);

/**
 * Simple API for SQLi detection - returns a SQLi fingerprint or NULL
 * is benign input
 *
 * \param[in] s  input string, may contain nulls, does not need to be null-terminated
 * \param[in] slen input string length
 * \param[out] fingerprint buffer of 8+ characters.  c-string,
 * \return 1 if SQLi, 0 if benign.  fingerprint will be set or set to empty string.
 */
int libinjection_sqli(const char** s, int *slen, int *b, char** fin0, char** fin1, char** fin2, char** fin3, char** fin4, char** fin5, char** fin6, char** fin7);

LIBINJECTION_END_DECLS

#endif /* LIBINJECTION_H */
