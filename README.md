# dwh_tool
DWH tool - created on MCS Hackathon (21.03.2018)

# Documentation
See [here](https://rawgit.com/BercziSandor/dwh_tool/master/doc/dwh_tool_pl.html)

# Installation
No installation needed, but there are some prerequisits:
 - 



# Usage
~~~plain
  dwh_tool.pl -f[unction] FUNCTION [-f[unction] FUNCTION...] -v[erbose] -h[elp]

FUNCTIONS 
  - checkCSVFile(INPUTFILE)
  - demo
  - generateTemplate(TABLENAME,INPUTFILE)
  - parseDdlFile(INPUTFILE)
  - parseInputRecord(TABLENAME,INPUTFILE)
  - parseAndSaveRecord(TABLENAME,INPUTFILE,OUTPUTFILE)

Examples:
  ./dwh_tool.pl -f demo
  ./dwh_tool.pl -f parseDdlFile(input/a_batch_input.ddl)
  ./dwh_tool.pl -f parseDdlFile(input/a_batch_input.ddl) -f checkCSVFile(input/d063a_batch_input.dat)
  ./dwh_tool.pl -f parseDdlFile(input/a_export_strg.ddl) -f generateTemplate(a_export_strg,input/demo_input_a_export_strg.dat)
  ./dwh_tool.pl -f parseDdlFile(input/a_export_strg.ddl) -f parseInputRecord(a_export_strg,input/demo_input_a_export_strg.dat)
  ./dwh_tool.pl -f parseDdlFile(input/a_export_strg.ddl) -f parseAndSaveRecord(a_export_strg,input/demo_input_a_export_strg.dat,demo_output_a_export_strg.dat)
~~~
