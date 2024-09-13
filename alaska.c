#define cast(T) (T)
#define size_of(T) sizeof(T)
#define len(X) ((size_of(X) / size_of((X)[0])))
#define str(X) ((string) {len(X) - 1, cast(u8*) (X)})

typedef unsigned char u8;
typedef unsigned long long u64;

typedef struct {
    u64 count;
    u8* data;
} string;

typedef struct {
    u8 major;
    u8 minor;
    u8 baby;
} Version;

typedef struct {
    string name;
    Version version;
} Package;

typedef struct {
    string layer_name;
    string keyboard_layout;
    string hostname;
    string timezone;
    Package* packages;
} Config;

// #include "config.c"

#include <stdio.h>
#include <stdarg.h>
#include <string.h>

static void print(string fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    for (u64 i = 0; i < fmt.count; i += 1) {
        if (fmt.data[i] == '%') {
            if (i + 1 >= fmt.count || fmt.data[i + 1] != '%') {
                string arg = va_arg(ap, string);
                printf("%.*s", (int) arg.count, arg.data);
                continue;
            }
            i += 1;
        }
        printf("%c", fmt.data[i]);
    }
    va_end(ap);
}

static _Bool strings_equal(string a, string b) {
    if (a.count != b.count) return 0;
    return memcmp(a.data, b.data, a.count) == 0;
}

int main(int argc, char** argv) {
    Config c = {0};
    c.layer_name = str("default");
    c.keyboard_layout = str("us");
    c.hostname = str("alaska");
    c.timezone = str("America/New_York");

    print(str("hostname: %\n"), c.hostname);
}
