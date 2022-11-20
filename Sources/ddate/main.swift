import Foundation
import ArgParser

// some constants, up here at the top of our lovely program
let cal = Calendar(identifier: .gregorian)
let xday = DateComponents(calendar: cal, year: 8661, month: 7, day: 5).date!
let todayFmt = "Today is %{%A, the %e day of %B%} in the YOLD %Y%N%nCelebrate %H"
let shortFmt = "%{%A, %B %d%}, %Y YOLD"
let tibsName = "St. Tib's Day"
let shortTibsName = "Tib's"
let seasonNames =  ["Chaos", "Chs", "Discord", "Dsc", "Confusion", "Cfn",
                    "Bureaucracy", "Bcy", "The Aftermath", "Afm"]
let dayNames =  ["Sweetmorn", "SM", "Boomtime", "BT", "Pungenday", "PD",
                 "Prickle-Prickle", "PP", "Setting Orange", "SO"]
let holyDays5 = ["Mungday", "Mojoday", "Syaday", "Zaraday", "Maladay"]
let holyDays50 =  ["Chaoflux", "Discoflux", "Confuflux", "Bureflux", "Afflux"]
let exclamations = ["Hail Eris!", "All Hail Discordia!", "Kallisti!", "Fnord.", "Or not.",
                    "Wibble.", "Pzat!", "P'tang!", "Frink!", "Slack!", "Praise \"Bob\"!",
                    "Or kill me.", "Grudnuk demand sustenance!", "Keep the Lasagna flying!",
                    "You are what you see.", "Or is it?", "This statement is false.",
                    "Lies and slander, sire!", "Hee hee hee!", "Hail Eris, Hack Swift!"]

// now, a couple utility functions before the main logic starts...
private func errExit(_ msg: String? = nil) -> Never {
    fputs("""
          Usage: ddate [options]
          
          \(parser.argumentHelpText())
          
          """, stderr)
    fputs("""
          Format Strings: (e.g.,  "Today is %{%A, the %E of %B%}!")
            %A  weekday        /  %a  weekday (short version)
            %B  season         /  %b  season (short version)
            %d  day of season  /  %e  ordinal day of season
            %Y  the Year of Our Lady of Discord
            %X  the number of days left until X-Day
          
            %H  name of the holy day, if it is one
            %N  directive to skip the rest of the format
                if today is not a holy day
          
            %{ ... %}  either announce Tibs Day, or format the
                       interior string if it is not Tibs Day
          
            %n  newline        /  %t  tab\n\n
          """, stderr)
    if let hasMsg = msg {
        fputs("Error: \(hasMsg)\n\n", stderr)
    }
    exit(1)
}

private func ordinal(_ n: Int) -> String {
  var formatted = String(n)
  let digit = (n/10 == 1) ? 4 : n%10 
  switch digit {
    case 1: formatted.append("st")
    case 2: formatted.append("nd")
    case 3: formatted.append("rd")
    default: formatted.append("th")
  }
  return formatted
}

private func isLeapYear(_ year: Int) -> Bool {
    if year % 400 == 0 { return true }
    if year % 100 == 0 { return false }
    if year % 4 == 0 { return true }
    return false
}

// main logic...
// figure out the day and format from the cmdline options provided
let todayArg = YMDArg()
let ymdParam = BasicParam(names: ["date","d"], initial: todayArg, help: "<Date> the date to present (defaults to today)")
let fmtParam = BasicParam(names: ["format","f"], initial: "", help: "<FmtString> describes how to format the date (see below)")
let helpParam = FlagParam(names: ["help", "h"], help: "displays this help text")

let parser = ArgParser(ymdParam,fmtParam,helpParam)
do {
    let extras = try parser.parseArgs(CommandLine.arguments.dropFirst())
    // allow the user to specify the date as an extra...
    if(helpParam.value) {
        errExit()
    } else if (extras.count == 1) && (ymdParam.value == todayArg) {
        try ymdParam.process(param: "date", arg: extras[0])
    } else if !extras.isEmpty {
        errExit("Extra arguments given!")
    }
} catch ArgumentErrors.invalidArgument(desc: let msg) {
    errExit(msg)
} catch {
    errExit("Could not process commandline arguments!")
}

// set up our state based on the given parameters...
let today = ymdParam.value.date // the day we will present to the user
var fmt : String  // the format string we will use
if(fmtParam.value.isEmpty) {
    fmt = (todayArg == ymdParam.value) ? todayFmt : shortFmt
} else {
    fmt = fmtParam.value
}

// Start computing basic properties of the date...
let leapYear = isLeapYear(cal.component(.year, from: today)) // cal.range(of: .day, in: .year, for: today)!.count == 366
let dayOfYear = cal.ordinality(of: .day , in: .year, for: today)!
let adjustedDay = dayOfYear - ((leapYear && cal.component(.month, from: today) > 2) ? 2 : 1)
let isTibs = leapYear && dayOfYear == (31+29)
let season = adjustedDay / 73
let seasonDay = adjustedDay % 73 + 1
let holyDay : String 
switch seasonDay {
  case 5: holyDay = holyDays5[season]
  case 50: holyDay = holyDays50[season]
  default: holyDay = ""
}

// Loop over 'fmt' and produce the output
var result = ""; result.reserveCapacity(256) // this is where the output will go
var idx = fmt.startIndex
while idx != fmt.endIndex {
  if fmt[idx] != "%" {
    result.append(fmt[idx])
  } else {
    fmt.formIndex(after: &idx)
    // if % was the last character, treat it like %%
    if idx == fmt.endIndex { fmt.formIndex(before: &idx) }

    // parse the formatting char
    switch fmt[idx] {
    case "A": result.append(isTibs ? tibsName : dayNames[2 * (adjustedDay % 5)])
    case "a": result.append(isTibs ? shortTibsName : dayNames[2 * (adjustedDay % 5) + 1])
    case "B": result.append(isTibs ? tibsName : seasonNames[2 * season])
    case "b": result.append(isTibs ? shortTibsName : seasonNames[2 * season + 1])
    case "d": result.append(isTibs ? shortTibsName : String(seasonDay))
    case "e": result.append(isTibs ? "Tibsith" : ordinal(seasonDay))
    case "H": result.append(holyDay)
    case "n": result.append("\n")
    case "N": if holyDay.isEmpty { idx = fmt.index(before: fmt.endIndex) }
    case "t": result.append("\t")
    case "X": let nf = NumberFormatter(); nf.numberStyle = .decimal
              let days = cal.dateComponents([.day],from: today, to: xday).day ?? 0
              result.append(nf.string(from: NSNumber(value: days))!)
    case "Y": result.append(String(cal.component(.year, from: today) + 1166))
    case ".": result.append(exclamations.randomElement()!)
    case "{": if isTibs {
                result.append(tibsName)
                idx = fmt.index(before: fmt.range(of: "%}")?.upperBound ?? fmt.endIndex)
              }
    case "}": break
    default: result.append(fmt[idx])
    }
  }
  fmt.formIndex(after: &idx)
}
print(result)
