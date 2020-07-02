# External FacterDB facts
A repo for storing custom external facterdb facts that are specific to your code and organization. 

http://logicminds.github.io/blog/2018-09-25-alternative-facts/

### Example get_facts.rb 
```
[root@pe-xl-core-0 example_external_facterdb_facts]# ruby get_facts.rb
[root@pe-xl-core-0 example_external_facterdb_facts]# tree facts/
facts/
└── 3.11.13
    └── Linux
        └── RedHat
            └── 7
                ├── pe-xl-compiler-0.puppet.vm.facts
                ├── pe-xl-core-0.puppet.vm.facts
                ├── pe-xl-core-1.puppet.vm.facts
                ├── pe-xl-db-0.puppet.vm.facts
                └── pe-xl-db-1.puppet.vm.facts

4 directories, 5 files
```
