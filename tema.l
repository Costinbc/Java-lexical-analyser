/* Bosoaga Costin 332CC */

%option noyywrap
%option stack

%{
    #include <cstdio>
    #include <cstdlib>
    #include <string>
    #include <unordered_map>
    #include <tuple>
    #include <vector>
    #include <algorithm>

    int publicCount = 0;
    int classCount = 0;
    int class_brackets = 0;
    int main_brackets = 0;
    int allocations = 0;
    bool finished_class = false;
    int getset_brackets = 1;
    std::string classes[100];
    int instances[100] = {0};
    bool attributes[100] = {false};
    std::unordered_map<std::string, std::vector<std::string>> getters;
    std::unordered_map<std::string, std::vector<std::string>> setters;
    std::unordered_map<std::string, int> instances_map;
    std::unordered_map<std::string, int> allocations_map;
%}

%x CLASS
%x CHECK_SET_GET
%x CHECK_MAIN
%x CHECK_INSTANCE


Alphanumeric [a-zA-Z0-9_]
Parameters [a-zA-Z0-9 ]+
Field "private "{Alphanumeric}+(""|\[\])" "{Alphanumeric}+";"
Getter "public "{Alphanumeric}+(""|\[\])" get"{Alphanumeric}+"()"
Setter public\ void\ set{Alphanumeric}+\({Parameters}
Constructor "public "{Alphanumeric}+"("
Instance "new "{Alphanumeric}+"("
Main "public static void main(String\[\] args)"
For for\ \([a-zA-Z0-9 ]+\ =\ [a-zA-Z0-9_]+("."[a-zA-Z0-9_]+)?\;\ [a-zA-Z0-9 ]+\ <\ [a-zA-Z0-9_]+(\.[a-zA-Z0-9_]+)?\;\ [a-zA-Z0-9_]+\+\+\)
EnhancedFor for\ \([a-zA-Z0-9 ]+\ \:\ [a-zA-Z0-9_]+\)
Allocation [a-zA-Z0-9_]+\[\]\ [a-zA-Z0-9_]+\ \=\ new\ [a-zA-Z0-9_]+\[[0-9]+\]

%%

"public class "{Alphanumeric}+ {
    publicCount++;
    classCount++;
    std::string match = yytext;
    class_brackets = 0;
    getset_brackets = 1;
    classes[classCount] = match.substr(13);
    // printf("Entering class %s\n", classes[classCount].c_str());
    yy_push_state(CLASS);
}

"class "{Alphanumeric}+ {
    classCount++;
    std::string match = yytext;
    class_brackets = 0;
    getset_brackets = 1;
    classes[classCount] = match.substr(6);
    // printf("Entering class %s\n", classes[classCount].c_str());
    yy_push_state(CLASS);
}

<CLASS>\/\/[^\n]* {
    /* eat up one-line comments */
}

<CLASS>\/\*[^*]*\*+([^/*][^*]*\*+)*\/ {
    /* eat up multi-line comments */
}

<CLASS>[ \t\n]+ {
    if(finished_class) {
        finished_class = false;
        yy_pop_state();
    }
}

<CLASS>"\{" {
    class_brackets++;
    // printf("Found opening bracket in class %s brackets number: %d\n", classes[classCount].c_str(), class_brackets);
}


<CLASS>"\}" {
    class_brackets--;
    // printf("Found closing bracket in class %s brackets number: %d\n", classes[classCount].c_str(), class_brackets);
    if(class_brackets == 0) {
        // printf("Leaving class %s\n", classes[classCount].c_str());
        yy_pop_state();
    }
}

<CLASS>{Field} {
    std::string match = yytext;
    // printf("Match: %s\n", match.c_str());
    std::string type = match.substr(8, match.find_first_of(" ", 8) - 8);
    std::string name = match.substr(match.find_first_of(" ", 8) + 1, match.find_first_of(";", 8) - match.find_first_of(" ", 8) - 1);
    name[0] = toupper(name[0]); 
    // printf("Field: %s %s\n", type.c_str(), name.c_str());
    getters[classes[classCount]].push_back(name + " " + type);
    setters[classes[classCount]].push_back(name);
    attributes[classCount] = true;
}

<CLASS>{Constructor} {
    // printf("Found constructor in class %s\n", classes[classCount].c_str());
    // printf("Match: %s\n", yytext);
    yy_push_state(CHECK_SET_GET);
}

<CLASS>{Main} {
    std::string match = yytext;
    std::string name = match.substr(match.find_first_of(" ", 0) + 1, match.find_first_of("(", 0) - match.find_first_of(" ", 0) - 1);
    // printf("Main: %s\n", name.c_str());
    yy_push_state(CHECK_MAIN);
}


<CLASS>. {
    if(finished_class) {
        finished_class = false;
        yy_pop_state();
    }
}

<CHECK_SET_GET>[ \t\n]+ {
    /* eat up white space */
}

<CHECK_SET_GET>\/\/[^\n]* {
    /* eat up one-line comments */
}

<CHECK_SET_GET>\/\*[^*]*\*+([^/*][^*]*\*+)*\/ {
    /* eat up multi-line comments */
}

<CHECK_SET_GET>"\{" {
    getset_brackets++;
}

<CHECK_SET_GET>"\}" {
    getset_brackets--;
    if(getset_brackets == 0) {
        getset_brackets = 1;
        finished_class = true;
        yy_pop_state();
    }
}

<CHECK_SET_GET>{Getter} {
    std::string match = yytext;
    std::string type = match.substr(7, match.find_first_of(" ", 7) - 7);
    std::string name = match.substr(match.find_first_of(" ", 7) + 1, match.find_first_of("(", 7) - match.find_first_of(" ", 7) - 1);
    name = name.substr(3);
    // printf("Getter: %s %s\n", type.c_str(), name.c_str());

    if(std::find(getters[classes[classCount]].begin(), getters[classes[classCount]].end(), name + " " + type) != getters[classes[classCount]].end()) {
        getters[classes[classCount]].erase(std::find(getters[classes[classCount]].begin(), getters[classes[classCount]].end(), name + " " + type));
        // printf("Found getter for %s\n", name.c_str());
    }
}

<CHECK_SET_GET>{Setter} {
    std::string match = yytext;
    std::string name = match.substr(match.find_first_of("set", 0) + 3, match.find_first_of("(", 0) - match.find_first_of("set", 0) - 3);
    name[0] = toupper(name[0]);
    // printf("Setter: %s\n", name.c_str());

    if(std::find(setters[classes[classCount]].begin(), setters[classes[classCount]].end(), name) != setters[classes[classCount]].end()) {
        setters[classes[classCount]].erase(std::find(setters[classes[classCount]].begin(), setters[classes[classCount]].end(), name));
        // printf("Found setter for %s\n", name.c_str());
    }
}

<CHECK_SET_GET>{Main} {
    // std::string match = yytext;
    // std::string name = match.substr(match.find_first_of(" ", 0) + 1, match.find_first_of("(", 0) - match.find_first_of(" ", 0) - 1);
    // printf("Main: %s\n", name.c_str());
    yy_push_state(CHECK_MAIN);
}

<CHECK_SET_GET>. {
    /* eat the rest */
}

<CHECK_MAIN>"\{" {
    main_brackets++;
    finished_class = true;
    // printf("Found opening bracket in main brackets number: %d\n", main_brackets);
}

<CHECK_MAIN>"\}" {
    main_brackets--;
    // printf("Found closing bracket in main brackets number: %d\n", main_brackets);
    if(main_brackets == 0) {
        // printf("Leaving main\n");
        yy_pop_state();
    }
}

<CHECK_MAIN>{Allocation} {
    std::string match = yytext;
    std::string array = match.substr(match.find_first_of(" ", 0) + 1, match.find_first_of("=", 0) - match.find_first_of(" ", 0) - 2);
    std::string size = match.substr(match.find_first_of("[", match.find_first_of("[", 0) + 1) + 1, match.find_first_of("]", 0) - match.find_first_of("[", 0) + 1);
    allocations_map[array] = std::stoi(size);
}

<CHECK_MAIN>{For} {
    std::string match = yytext;
    int semi_colon = match.find_first_of(";", 0);
    std::string from = match.substr(match.find_first_of("=", 0) + 1, semi_colon - match.find_first_of("=", 0) - 1);
    semi_colon = match.find_first_of(";", semi_colon + 1);
    std::string to = match.substr(match.find_first_of("<", 0) + 1, semi_colon - match.find_first_of("<", 0) - 1);
    std::string array = to.substr(1, to.find_first_of(".", 0) - 1);
    allocations = allocations_map[array];
    yy_push_state(CHECK_INSTANCE);
}

<CHECK_MAIN>{EnhancedFor} {
    std::string match = yytext;
    std::string from = match.substr(match.find_first_of(" ", 0) + 1, match.find_first_of(":", 0) - match.find_first_of(" ", 0) - 1);
    std::string to = match.substr(match.find_first_of(":", 0) + 2, match.find_first_of(")", 0) - match.find_first_of(":", 0) - 2);
    // printf("EnhancedFor:%s\n", to.c_str());
    allocations = allocations_map[to];
    yy_push_state(CHECK_INSTANCE);
}

<CHECK_INSTANCE>"\}" {
    // printf("Leaving instance\n");
    allocations = 0;
    yy_pop_state();
}

<CHECK_INSTANCE>{Instance} {
    std::string match = yytext;
    std::string name = match.substr(match.find_first_of(" ", 0) + 1, match.find_first_of("(", 0) - match.find_first_of(" ", 0) - 1);
    if(allocations > 0){
        // printf("%d instances: %s\n",allocations , name.c_str());
        if(strcmp(name.c_str(), "String") != 0){
            instances_map[name]+=allocations;
        }
    }
    else {
        // printf("Instance: %s\n", name.c_str());
        if(strcmp(name.c_str(), "String") != 0)
            instances_map[name]++;
    }
}

<CHECK_INSTANCE>\/\/[^\n]* {
    /* eat up one-line comments */
}

<CHECK_INSTANCE>[ \t\n]+ {
    /* eat up white space */
}

<CHECK_INSTANCE>. {
    /* eat the rest */
}

<CHECK_MAIN>{Instance} {
    std::string match = yytext;
    std::string name = match.substr(match.find_first_of(" ", 0) + 1, match.find_first_of("(", 0) - match.find_first_of(" ", 0) - 1);
    // printf("Instance: %s\n", name.c_str());
    if(strcmp(name.c_str(), "String") != 0)
        instances_map[name]++;
}

<CHECK_MAIN>\/\/[^\n]* {
    /* eat up one-line comments */
}

<CHECK_MAIN>[ \t\n]+ {
    /* eat up white space */
}

<CHECK_MAIN>. {
    /* eat the rest */
}

"{"[^}\n]*"}"          /* eat up one-line comments */
[ \t\n]+               /* eat up white space */
.  

%%

int main(int argc, char** argv) {

    FILE* inputFile = fopen(argv[1], "r");
    if (!inputFile) {
        perror("Error opening input file");
        return 1;
    }

    yyin = inputFile;

    yylex(); 

    fclose(inputFile);

    FILE* outputFile = fopen(argv[2], "w");
    if (!outputFile) {
        perror("Error opening output file");
        return 1;
    }

    

    if(publicCount == 2) {
        fprintf(outputFile, "Error:\nToo many public classes\n");
    }
    
    fprintf(outputFile, "Sunt %d clase: ", classCount);

    for (int i = 0; i < classCount; i++) {
        if(i == classCount - 1)
            fprintf(outputFile, "%s ", classes[i + 1].c_str());
        else
            fprintf(outputFile, "%s, ", classes[i + 1].c_str());
    }
    fprintf(outputFile, "\n");

    for (int i = 0; i < classCount; i++) {
        if(instances_map.find(classes[i + 1]) != instances_map.end()) {
            fprintf(outputFile, "Obiecte %s: %d\n", classes[i + 1].c_str(), instances_map[classes[i + 1]]);
        }
        else {
            fprintf(outputFile, "Obiecte %s: 0\n", classes[i + 1].c_str());
            // printf("Obiecte %s: 0\n", classes[i + 1].c_str());
        }
    }


    for (int i = 0; i < classCount; i++) {
        fprintf(outputFile, "%s:\n", classes[i + 1].c_str());
        // printf("%s:\n", classes[i + 1].c_str());
        if(attributes[i + 1]){
            bool get_ok = true;
            bool set_ok = true;
            if(!getters[classes[i + 1]].empty()){
                get_ok = false;
                // printf("Getters for %s:\n", classes[i + 1].c_str());
                fprintf(outputFile, "Metoda “get” nu este implementata pentru toate atributele\n");
            }
            if(!setters[classes[i + 1]].empty()){
                set_ok = false;
                fprintf(outputFile, "Metoda “set” nu este implementata pentru toate atributele\n");
            }
            if(set_ok && get_ok){
                fprintf(outputFile, "Metodele “get” si “set” sunt implementate\n");
            }
        }
        else {
            fprintf(outputFile, "Nu exista atribute\n");
        }
    }

    fclose(outputFile);

    return 0;
}
