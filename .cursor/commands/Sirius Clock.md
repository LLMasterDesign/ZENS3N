# /sirius Command

▛▞ Purpose:: Run Sirius clock and display time/date

▛▞ Usage::
- `/sirius` - Display Sirius time and current date/time

## Behavior

When you type `/sirius`:
1. Execute `ruby sirius.clock.rb` to get Sirius time (⧗-YY.SSS)
2. Get current date/time: `date '+%Y-%m-%d %H:%M:%S'`
3. Display both in the chat

**Output Format:**
```
Sirius Time: ⧗-YY.SSS
Date/Time: YYYY-MM-DD HH:MM:SS
```

## Implementation

Execute:
```bash
!CMD.CENTER/STATIONS/Sirius.Station/sirius
```

Or from workspace root:
```bash
./!CMD.CENTER/STATIONS/Sirius.Station/sirius
```

The script will:
1. Calculate Sirius time using `sirius.clock.rb`
2. Get current date/time
3. Display both in the chat

Display results directly in chat response.

:: ∎

