%{
#include <stdio.h>
int  yylex  (void);
void  yyerror  (const char *str);


int isShouldAdd = 0;
int keyId = 1;
int itemDepth = 0;

#define SIZE 1024
#define MAX_LINE_LENG 1024

struct DataItem {
   char idName[100];
   char type[100];
   char value[100];
   int key;
   int depth;
};
// struct DataItem* globalHashArray[SIZE*SIZE];
struct DataItem* *hashArray;

int hashCode(int key) {
   return key % SIZE;
}
//Creates a symbol table.
struct DataItem* * create(){
  static struct DataItem* newHashArray[SIZE] ;
  return newHashArray;
};
//Returns index of the entry for int key
int lookup(char *idName) {
   //get the hash
   int hashIndex = 1;
   int isFind = 0;
   //move in array until an empty
   // printf("lookup:  %s\n", idName);
   // printf("hashArray[hashIndex]:  %s\n", hashArray[1]->idName);
   while(hashArray[hashIndex] != NULL) {
      if(strcmp(hashArray[hashIndex]->idName, idName) == 0)
      {
        isFind = 1;
        break;
      }
      else
      {
        ++hashIndex;
      }
   }
   if(isFind == 1){
     return hashIndex;
   }
   else{
     return -1;
   }
}
//Inserts s into  the symbol table
void insert(char *idName , char *type, char *value) {
	
	// if (lookup(idName) < 1)
	// {
	   struct DataItem *item = (struct DataItem*) malloc(sizeof(struct DataItem));
	   strcpy(item->idName, idName);
	   strcpy(item->type, type);
		strcpy(item->value, value);
		item->depth = itemDepth;
	   item->key = keyId;

	   //get the hash
	   int hashIndex = hashCode(keyId);

		//move in array until an empty or deleted cell
		int f = 1;
		// for(int i = 1;i < SIZE;i++)
		// {
	 // 		  if(hashArray[i]->idName != NULL &&  (strcmp(idName, hashArray[i]->idName) == 0))
	 // 		  {
		// 			f = 0;
		// 	  }
	 //    }
		if (f) 
		{
		 	hashArray[hashIndex] = item;
			keyId ++;
		}
	// }
}
//Dumps all entries of the symbol table. returns index of the entry.
void dump() {
   for(int i = 1;i < SIZE;i++)
   {
 		if(hashArray[i] != NULL)
	    {
	      printf("%d: %s, %s, %s %d \n", i, hashArray[i]->idName , hashArray[i]->type , hashArray[i]->value , hashArray[i]->depth);
	    }
 	}
}

void clear() {
   for(int i = 1;i < SIZE;i++)
   {
 		if(hashArray[i] != NULL)
	    {
	      	hashArray[i] = NULL;
	    }
 	}
}
%}

%union{
  char typeOF[200];
  char val[200];
  double double_type;
  int int_type;
  int int_val;
}

%token <val> STR TRUE FALSE IDENTIFIER 
%token <double_type> REALCONSTANTS 
%token <int_type> INTEGER
%token BOOL BREAK CASE CONST CONTINUE DEFAULT ELSE FOR FUNC GO IF 
%token IMPORT INT NIL PRINT PRINTLN REAL RETURN STRINGKEYWORD 
%token STRUCT SWITCH VAR VOID WHILE READ

%token LE_OP GE_OP EQ_OP NE_OP 
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN
%start program

%type  <val> value_declaration program primary_expression type_specifier
%type <int_type> number_declaration

%%

primary_expression
	: value_declaration
	| declarator_list 
	| primary_expression value_declaration 
	| primary_expression declarator_list
	;

unary_expression
	: primary_expression
	| '-' primary_expression
	;

multiplicative_expression
	: unary_expression
	| multiplicative_expression '*' unary_expression
	| multiplicative_expression '/' unary_expression
	| multiplicative_expression '%' unary_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression
	;


relational_expression
	: additive_expression
	| relational_expression '<' primary_expression
	| relational_expression '>' primary_expression
	| relational_expression LE_OP primary_expression
	| relational_expression GE_OP primary_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression
	;

assignment_expression
	: inclusive_or_expression
	| inclusive_or_expression '=' assignment_expression
	;

expression
	: assignment_expression
	| expression assignment_expression
	;


type_specifier
	: BOOL
	| STRINGKEYWORD
	| REAL
	| INT
	| VOID
	;

value_declaration
	: STR  {
		strcpy($$, $1);
	}
	| TRUE  {
		strcpy($$, $1);
	}
	| FALSE {
		strcpy($$, $1);
	}
	| INTEGER 
	{
		char tempStr[50];
		sprintf( tempStr, "%d", $1 );
		strcpy($$, tempStr);
	}
	| REALCONSTANTS 
	{
		char tempStr[50];
		sprintf( tempStr, "%g", $1 );
		strcpy($$, tempStr);
	}
	;

// when function be called
declarator_list
	: declarator
	// | declarator_list ',' declarator_list
	| declarator_list '(' declarator_list ')' 
	{
		// insert(&$1, &$2 , "");
	}
	| declarator_list ','
	;

declarator
	: IDENTIFIER  {
		// strcpy(yylval.idName , $1);
	}
	| value_declaration {
		// strcpy(yylval.value , $1);
	}
	;

// when funtion be defined
parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;
parameter_declaration
	: IDENTIFIER type_specifier 
	{
		insert(&$1, &$2 , "");
		printf("aaa:  %s\n", $1);
	}
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

declaration
	: CONST IDENTIFIER '=' value_declaration {
		insert($2, "const" , $4);
	}
	| VAR IDENTIFIER type_specifier {
		insert($2, $3, "");
	}
	| VAR IDENTIFIER type_specifier '=' value_declaration {
		insert($2, $3, "");
	}
	| VAR IDENTIFIER '[' INTEGER ']' type_specifier {
		insert($2, "array" , $6);
	}
	;

	simple_statment
	: IDENTIFIER '[' INTEGER ']' '=' expression 
	| PRINT expression
	| PRINTLN expression 
	| READ IDENTIFIER 
	| RETURN 
	| RETURN expression
	;

compound_start
	: '{'
	{
		if (isShouldAdd == 1)
		{
			itemDepth++;
		}
		else{
			isShouldAdd++;
		}
	}
	;

compound_end
	: '}'
	{
		itemDepth--;
	}
	;

compound_statement
	: compound_start statement_list compound_end
	| compound_start declaration_list compound_end
	| compound_start declaration_list statement_list compound_end
	| compound_start compound_end
	;

expression_statement
	:  expression 
	;

selection_statement
	: IF '(' expression ')' statement
	| IF '(' expression ')' statement ELSE statement
	;

iteration_statement
	: FOR '(' expression_statement ')' statement
	| FOR '(' expression_statement ";" expression_statement ')' statement
	| FOR '(' expression_statement ";"  expression_statement ";"  expression_statement ')' statement
	;

jump_statement
	: GO IDENTIFIER '(' expression_statement ')'
	;

statement_list
	: statement
	| statement_list statement
	;

statement
	: simple_statment
	| compound_statement
	| expression_statement 
	| selection_statement 
	| iteration_statement 
	| jump_statement 
	;

func_expression:
	FUNC {
		isShouldAdd = 0;
		itemDepth++;
	};

function_definition 
	: func_expression  type_specifier IDENTIFIER '(' parameter_list ')' compound_statement 
	{
		insert($3, $2, "");
	}
	| func_expression IDENTIFIER '(' parameter_list ')' compound_statement 
	{
		insert($2, "", "");
	}
	| func_expression type_specifier IDENTIFIER '('  ')' compound_statement 
	{
		insert($3, $2, "");
	}
	| func_expression IDENTIFIER '('  ')' compound_statement 
	{
		insert($2, "", "");
	}
	;

external_declaration
	: function_definition
	| declaration_list
	| IDENTIFIER '(' declarator_list ')' 
	;

program
	: external_declaration
	| program external_declaration
	;

%%

void yyerror(const char *str){
    printf("error:%s\n",str);
}

int yywrap(){
    return 1;
}

int main()
{
	hashArray = create();

    yyparse();
    printf("%s\n", "Symbol Table:");
  	dump();
  	return 0;
}
