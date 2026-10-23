#include <netdb.h>
#include <stddef.h>

/*
 * Fix for Subway Surfers / Unity IL2CPP crash when Wi-Fi is active on Linux.
 *
 * Root cause:
 * In Android Bionic 64-bit, struct addrinfo has ai_canonname at offset 24 and
 * ai_addr at offset 32. In standard Linux glibc, ai_addr is at offset 24 and
 * ai_canonname is at offset 32.
 * When Wi-Fi is active, libil2cpp calls getaddrinfo() to resolve Sybo/Unity telemetry
 * endpoints. Because getaddrinfo() is passed through to glibc, it returns glibc-shaped
 * addrinfo structs. libil2cpp dereferences offset 32 expecting struct sockaddr, but
 * gets a string pointer instead, subsequently crashing with SIGSEGV in inet_ntop().
 *
 * This shim intercepts getaddrinfo() and returns EAI_NONAME, gracefully routing
 * Unity IL2CPP into offline mode without any crashes.
 */
int getaddrinfo(const char *node, const char *service,
                const struct addrinfo *hints,
                struct addrinfo **res) {
    if (res) *res = NULL;
    return EAI_NONAME;
}
