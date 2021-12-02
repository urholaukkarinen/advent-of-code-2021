@echo off
setlocal enabledelayedexpansion

set a=
set b=
set c=
set prev_sum=
set first_result=-1
set second_result=-1

for /f "usebackq delims=" %%l in ("input.txt") do (
    if %%l gtr !c! (
        set /a first_result+=1
    )

    set a=!b!
    set b=!c!
    set c=%%l

    if [!a!] neq [] if [!b!] neq [] if [!c!] neq [] (
        set /a sum=a+b+c

        if !sum! gtr !prev_sum! (
            set /a second_result+=1
        )

        set prev_sum=!sum!
    )
)

echo Part 1: %first_result%
echo Part 2: %second_result%