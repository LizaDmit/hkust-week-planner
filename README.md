# Week Planner

A small stand-in for the HKUST Timetable Planner: pull the sections you might take,
drop them on a week grid, and see immediately whether they collide.

Two pieces, nothing to build:

- `scrape.py` - reads the Class Schedule & Quota pages and writes `data/courses.json` + `data/courses.js`
- `index.html` - the grid. Plain HTML, CSS and JS, no framework, no bundler

## Run it

```bash
pip install -r requirements.txt

# 2026-27 Fall, only the courses you're actually weighing
python scrape.py --term 2610 --subjects COMP ECON MGMT \
    --courses COMP3711 COMP2211 ECON2123 ECON3014 MGMT2110
```

Then open `index.html` - double-clicking works, no server needed.

Term codes are `YYTT`: `YY` is the first year of the academic year, `TT` is
`10` Fall, `20` Winter, `30` Spring, `40` Summer. So `2610` is 2026-27 Fall.

### If the scraper can't reach the site

The quota site sometimes refuses non-browser requests, and the term you want may
not be published yet. Fallback: open the subject page in Chrome, save it
(Cmd+S, "Web Page, HTML Only"), then parse the file:

```bash
python scrape.py --file COMP.html --subject COMP --term 2610
```

Repeat per subject if needed - each run overwrites `data/`, so merge by editing
`data/courses.json` directly, or scrape all subjects in one go.

## Using the grid

- Search a course, expand it, tick the sections you're considering
- Blocks land on the week; each course keeps its own colour
- Overlapping blocks split the column and get a red hatch, and every collision is
  listed under the grid with the exact overlapping minutes
- Each day header shows committed hours, so the open stretches are easy to read off
- Picks are remembered in the browser, per device

## Files

```
scrape.py           fetch + parse -> data/
data/courses.js     what index.html loads (ships with sample data)
data/courses.json   same data, for anything else you want to do with it
index.html          the app
```

## Caveats

- The parser targets the current quota-page markup (`div.course` + a sections
  table). If the Registry changes the layout it will come back with 0 courses -
  that's the signal to adjust the selectors in `parse_subject_page`.
- Sections listed as TBA have no time, so they can't be placed on the grid. They
  are listed under the grid instead of being silently dropped.
- The data that ships in `data/courses.js` is made up. The app shows a banner
  until the scraper replaces it.

## Deploy

Push the folder and turn on GitHub Pages (Settings - Pages - deploy from branch,
root). It's static, so it just works.
