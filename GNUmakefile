OCAMLC=$(if $(shell which ocamlc.opt),ocamlc.opt,ocamlc)
NOCAMLC=$(if $(shell which ocamlopt.opt),ocamlopt.opt,ocamlopt)
CAMLPP=camlp4o
#$(if $(shell which camlp4o.opt),camlp4o.opt,camlp4o)

GTKPP := -pp "$(CAMLPP) pa_macro.cmo -DGTK"
NOGTKPP := -pp "$(CAMLPP) pa_macro.cmo -UGTK"

INCLUDE = -I src
OCAMLOPTS = unix.cma str.cma -g -warn-error A $(INCLUDE)
NOCAMLOPTS = unix.cmxa str.cmxa -warn-error A $(INCLUDE)

MLFILES = \
	src/Util.ml \
	src/Architecture.ml \
	src/Config.ml \
	src/Debug.ml \
	src/Parser.ml \
	src/Lexer.ml \
	src/InputOutput.ml \
	src/FileHandling.ml \
	src/Entry.ml \
	src/Quiz.ml \
	src/Data.ml \
	src/CardBox.ml \
	src/ConsoleUi.ml

# Adjust these based on whether you want GTK or not
#OCAMLOPTS += $(NOGTKPP)
#NOCAMLOPTS += $(NOGTKPP)
#INCLUDE += $(NOGTKPP)
MLFILES += src/GtkUi.ml 
OCAMLOPTS += -I +lablgtk2 lablgtk.cma $(GTKPP)
NOCAMLOPTS += -I +lablgtk2 lablgtk.cmxa $(GTKPP)
INCLUDE += $(GTKPP)



MLIFILES = $(filter-out src/Architecture.mli src/Lexer.mli, $(patsubst %.ml,%.mli, $(MLFILES)))
CMIFILES = $(patsubst %.ml,%.cmi, $(MLFILES))
OBJS = $(patsubst %.ml,%.cmo, $(MLFILES)) 
NOBJS = $(patsubst %.ml,%.cmx, $(MLFILES))

DEPEND += src/Lexer.ml src/Parser.ml src/main.ml

# Files that need to be generated from other files


# When "make" is invoked with no arguments, we build an executable 
# typechecker, after building everything that it depends on
all: cardflasher
opt: cardflasher.opt

# Build an executable typechecker
cardflasher: $(OBJS) src/main.cmo
	@echo Linking $@
	$(OCAMLC) $(OCAMLOPTS) -o $@ $^

cardflasher.opt: $(NOBJS) src/main.cmx
	@echo Linking $@
	$(NOCAMLC) $(NOCAMLOPTS) -o $@ $^

# Create a dependency graph, in postscript format, for the modules
depgraph:
	ocamldoc -dot $(MLIFILES) $(MLFILES) -o depgraph.dot
	dot -Tps depgraph.dot > depgraph.ps

tydepgraph:
	ocamldoc -dot -dot-types $(MLIFILES) $(MLFILES) -o tydepgraph.dot
	dot -Tps tydepgraph.dot > tydepgraph.ps

docs: all
	ocamldoc -v -html -d doc/ocamldoc -keep-code -sort \
	-all-params -colorize-code -I src $(MLIFILES) $(MLFILES)

# Compile an ML module interface
%.cmi : %.mli
	$(OCAMLC) -c $(OCAMLOPTS) $<

# Compile an ML module implementation to bytecode
%.cmo : %.ml
	$(OCAMLC) -c $(OCAMLOPTS) $<

# Compile an ML module implementation to native code
%.cmx : %.ml
	$(NOCAMLC) -c $(NOCAMLOPTS) $<

# Generate ML files from a Parser definition file
%.ml %.mli: %.mly
#	@rm -f $^
	ocamlyacc -v $< 
#	@chmod -w $^

# Generate ML files from a Lexer definition file
%.ml %.mli: %.mll
	@rm -f $@
	ocamllex $<
	@chmod -w $@

install: cardflasher 
	cp cardflasher /usr/local/bin/

install-opt: cardflasher.opt
	cp cardflasher.opt /usr/local/bin/

# Clean up the directory
clean::
	rm -rf $(OBJS) $(NOBJS) $(CMIFILES) \
		src/Lexer.ml src/Parser.ml src/Parser.mli src/Parser.output \
		cardflasher src/*~ depgraph.dot depgraph.ps \
		cardflasher.opt 

# Rebuild intermodule dependencies
depend:: $(DEPEND) 
	ocamldep $(INCLUDE) $(MLIFILES) $(MLFILES) $(DEPEND) > .depend

# Word count
wc:: clean
	wc $(filter-out src/Lexer.ml src/Parser.ml src/Parser.mly, $(MLFILES) $(MLIFILES)) \
		src/Parser.mly src/Lexer.mll 

# Include an automatically generated list of dependencies between source files
include GNUmakefile.deps
