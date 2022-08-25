/*  Inteligencia Artificial - 2022/1 - IC/UFRJ
    Prof. Joao Carlos Pereira da Silva
    Alunos: Lorena Mamede (DRE: 117039095)
            Roberto Leonie Ferreira Moreira (DRE: 116062192)
    
    Tarefa 2 - Busca Nao Informada
    Problema das Jarras
*/



/**************************ITEM A: Definir os estados finais do problema.**************************/   


/* Predicado unario objetivo(_).
 * A primeira posicao indica o estado final da Jarra 1.
 * A segunda posicao indica o estado final na Jarra 2.
 * */

objetivo((2, 0)).
objetivo((2, 1)).
objetivo((2, 2)).
objetivo((2, 3)).


/******************ITEM B: Definir regras/clausulas acao((J1,J2),ACAO,(J1a,J2a)).******************/

/* Regras min() auxiliares, retorna o menor valor entre duas entradas
 * @param A, B: valores a serem comparados
 * */

min(A,B,A) :- A =< B.
min(A,B,B) :- A > B.


/*Clausulas que representam as transicoes entre os estados
 * @param J1,J2 estados iniciais da Jarra 1 e da Jarra 2
 * @param acao nome da acao que modificara o estado
 * @param (J1a,J2a) estado resultante da acao
 * */
acao((J1,J2), encher1, (4,J2)) :- J1 < 4.       % so eh possivel encher a jarra 1 se ela tem menos de 4L
acao((J1,J2), encher2, (J1,3)) :- J2 < 3.       % so eh possivel encher a jarra 2 se ela tem menos de 3L

acao((J1,J2), esvaziar1, (0,J2)) :- J1 > 0.     % so eh possivel esvaziar jarra 1 se ela nao esta vazia
acao((J1,J2), esvaziar2, (J1,0)) :- J2 > 0.     % so eh possivel esvaziar jarra 2 se ela nao esta vazia

acao((J1,J2), passar12, (J1a,J2a)) :-
    J2 < 3,                                     % jarra 2 nao pode estar cheia
    J1 > 0,J1 =< 4,                             % precisa ter agua na jarra 1
    min(J1,(3-J2),Menor),                       % sera passado o menor valor entre o que esta em jarra 1
                                                % e o quanto falta para encher a jarra 2
    J1a is J1 - Menor,                          % jarra 1 apos tera o conteudo inicial - a transferencia
    J2a is J2 + (J1 - J1a),                     % jarra 2 apos tera jarra 2 + o que estava em J1 mas que nao ficou em J1
    J1a =< 4,                                   % jarra 1 apos deve ter menor ou igual a 4L
    J2a =< 3.                                   % jarra 2 apos deve ter menor ou igual a 3L
    
acao((J1,J2), passar21, (J1a,J2a)) :-
    J1 < 4,                                     % jarra 1 nao pode estar cheia
    J2 > 0, J2 =< 3,                            % precisa ter agua na jarra 2
    min(J2,(4-J1),Menor),                       % sera passado o menor valor entre o que esta em jarra 2
                                                % e o quanto falta para encher a jarra 1
    J2a is J2 - Menor,                          % jarra 2 apos tera o conteudo inicial - a transferencia
    J1a is J1 + (J2 - J2a),                     % jarra 1 apos tera jarra 1 + o que estava em J2 mas que nao ficou em J2
    J1a =< 4,                                   % jarra 1 apos deve ter menor ou igual a 4L
    J2a =< 3.                                   % jarra 2 apos deve ter menor ou igual a 3L


/*********************************ITEM C: Criar predicado Vizinho.*********************************/

/* Retorna os estados resultantes de todas as posiveis 
 * transicoes (acoes) de um estado N. Esses vizinhos
 * sao incorporados a lista FilhosN.
 * 
 * @param N estado antes da acao
 * */ 

vizinhos(N, FilhosN) :- 
    findall(Estado, acao(N, _, Estado), FilhosN).



/***************************ITEM D: Algoritmo de Busca em Largura (BFS).***************************/

/*  Consulta: ?- busca([(0,0)]). 
    O que ocorre? Vai imprimir true "para sempre", uma vez que
    sempre esta achando estados vizinhos. */

/* Caso Base: o node atual da busca eh um dos estados 
 * finais (objetivo), finalizando a busca.
 * 
 * @param Node o estado atual da busca
 * @param _  o resto dos nodes que serao expandidos
 * */ 
busca([Node|_]) :- 
    /*  write(Node),
        write(" / "), */
    objetivo(Node).

/* Caso Geral: o node nao eh o estado final,
 * logo expandimos sua fronteira ao adicionar seus
 * filhos ao final da fila. Tratar a fronteira como 
 * uma FILA.
 * 
 * @param Node nó atual da busca
 * @param F1 cauda da fila, representa o pop(N) apos
 * sua verificacao.
 * */   
busca([Node|Queue]) :- 
    /*  write(Node),
        write(" / "), */
    vizinhos(Node,Neighboors),
    add_to_frontier(Neighboors,Queue,UpdatedQueue),
    busca(UpdatedQueue).


/* Adiciona novos nodes a fila de busca.
 * A adicao desses nodes ao final da fila
 * determina o metodo de Busca em Largura
 * 
 * @param NN novos nodes
 * @param Queue fila que determina a ordem de expansao
 * @param UpdatedQueue fila retornada apos adicao
 * */
add_to_frontier(NN,Queue,UpdatedQueue) :- 
    append(Queue,NN,UpdatedQueue).


/* O que ocorre e Por que: 
 * Desejamos, a partir do estado inicial das jarras vazias (0,0),
 * obter uma lista que mostre o caminho ate o estado final
 * objetivo(2,_). Para isso, faremos a consulta ?- busca([(0,0)]).
 * 
 * A saida do console sera true para um vizinho encontrado ou 
 * false para um vizinho nao encontrado. Nesse, exemplo com entrada
 * [(0,0)], a busca em largura vai primeiro enfileirar todos os nós
 * do nível atual, antes de expandir seus filhos.
 *  
 * Todavia, da forma como o programa esta implementado ate aqui, 
 * nao estamos limitando esse enfileiramento apenas aos filhos, mas
 * sim aos vizinhos de forma geral, isso inclui os ancestrais do node.
 * 
 * Isso permite a ocorrencia de estados repetidos na fila, e, 
 * consequentemente, a expansao desses nós repetidos em novas subárvores 
 * que ja ocorreram anteriormente na arvore de busca. Tais arvores tambem 
 * gerarao estados repetidos, fazendo o programa, que imprime "true;" 
 * a cada passo, entrar em loop. Entretanto, o programa ainda eh 
 * deterministico.
 * 
 * Isso nos leva ao item E da Tarefa.
 * */



/*************ITEM E: Modificar o programa para guardar as configuracoes das Jarras.*************/

   
/* Caso Base: o node atual da busca eh um dos estados 
 * finais (objetivo), finalizando a busca.
 * 
 * Exemplo de consulta:
 * ?- busca([(0,0)],[],Solucao).
 * 
 * @param Node o estado atual da busca
 * @param _  o resto dos nodes que serao expandidos
 * @param Solucao lista retornada com a expansao da
 * fronteira ate o objetivo
 * @param NosVisitados lista com todos os nos visitados
 * ate encontrar o objetivo
 * */ 
busca([Node|_],NosVisitados, Solucao) :-
    objetivo(Node),        
    append(NosVisitados,[Node],Solucao).  


 /* Caso Geral: o node nao eh o estado final,
 * logo expandimos sua fronteira ao adicionar seus
 * filhos ao final da fila. 
 * 
 * Exemplo de consulta: 
 * ?- busca([(0,0)], Sequencia).
 *  
 * @param Node nó atual da busca
 * @param F1 cauda da fila, representa o pop(N) apos
 * sua verificacao.
 * @param NosVisitados registra os Nos pelos quais
 * estamos passando
 * @param Solucao lista retornada com a expansao da
 * fronteira ate o objetivo
 * */   
busca([Node|F1],NosVisitados,Solucao) :- 
    vizinhos(Node,NN),
    add_to_frontier(NN,F1,F2),
    
    append(NosVisitados, [Node], NosVisitadosAtualizados),
    busca(F2,NosVisitadosAtualizados, Solucao).
	

/*  As listas geradas em cada passo do programa sao as listas 
    contendo as fronteiras da arvore de busca do programa.
    Ou seja, uma lista com TODAS AS FOLHAS da arvore de busca
    ou TODAS AS POSSIBILIDADES DE ESTADOS DAS JARRAS naquele
    dado momento. */

/*  Aqui no item E, mais uma vez o programa entra em loop devido
    a criacao de estados das jarras repetidos que, por sua vez,
    gerarao novas subarvores que tambem gerarao estados repetidos.
    Portanto, o programa entra em loop e um estouro de pilha ocorre
    na Global Stack do Prolog. 
    O tratamento deste problema se da pela
    ELIMINACAO DE ESTADOS REPETIDOS, conforme veremos no item a seguir. */




/***************************ITEM F: Evitar os estados repetidos.***************************/


/* Retorna os filhos do nó atual
 * se difere do vizinhos por não incluir anscestrais
 * contornando existencia de ciclos na arvore
 * 
 * @param CurrentNode nó atual da busca
 * @param Children lista retornada com os filhos 
 * @param VisitedNodes nós já visitados, lista usada para nao usarmos
 * nos ja visitados como parte dos filhos
 * @param Queue fila, usado para nao retornarmos integrantes
 * da fila como parte dos filhos
 * */
children(CurrentNode, Children, VisitedNodes, Queue) :- 
    findall(FinalResults, acao(CurrentNode, _, FinalResults), Neighboors), 
    findall(X, (member(X,Neighboors), not(member(X,VisitedNodes)), not(member(X,Queue))), Children).

/* Caso Base: o node atual da busca eh um dos estados 
 * finais (objetivo), finalizando a busca.
 * 
 * Exemplo de consulta:
 * ?- buscaSemRepeticao([(0,0)],[],Solution).
 * 
 * @param Node o estado atual da busca
 * @param VisitedNodes nos visitados ate se encontrar o objetivo
 * @param Solution lista de filhos expandidos, representa os nos 
 * do mesmo nivel da arvore
 * @param _ fila
 * */ 
buscaSemRepeticao([Node|_], VisitedNodes, Solution):- 
    objetivo(Node),
    append(VisitedNodes, [Node], Solution).
    

/* Caso Geral: o node nao eh o estado final,
 * logo expandimos sua fronteira ao adicionar seus
 * filhos ao final da fila. 
 * 
 * Exemplo de consulta:
 * ?- buscaSemRepeticao([(0,0)], [], Solution).
 * 
 * @param Node nó atual da busca
 * @param Queue cauda da fila, representa o pop(N) apos
 * sua verificacao.
 * @param VisitedNodes precisa ser iniciado com [] na
 * consulta, essa lista funciona como cache de nos
 * visitados, sua verificacao evita a repeticoes de nos
 * @param Solution lista retornada com todos os nos
 * visitados ate a solucao.
 * */  
buscaSemRepeticao([Node|Queue], VisitedNodes, Solution):-
    append(VisitedNodes, [Node], UpdatedVisitedNodes),
    
    children(Node, Children, UpdatedVisitedNodes, Queue),
    add_to_frontier(Children, Queue, Frontier),
    buscaSemRepeticao(Frontier, UpdatedVisitedNodes, Solution).
	

/**********************ITEM G: Implementar Busca em Profundidade (DFS).**********************/
 
/* Caso Base: o node atual da busca eh um dos estados 
 * finais (objetivo), finalizando a busca.
 * 
 * Exemplo de consulta:
 * ?- buscaSemRepeticaoDFS([(0,0)], [], Expansion).
 * 
 * @param Node o estado atual da busca
 * @param _ pilha
 * @param VisitedNodes nós visitados
 * @param Solution lista retornada de com caminho ate
 * o objetivo
 * */ 
buscaSemRepeticaoDFS([Node|_], VisitedNodes, Solution):- 
    objetivo(Node),
    append(VisitedNodes,[Node], Solution).
   
 /* Caso Geral: o node nao eh o estado final,
 * logo expandimos sua fronteira ao adicionar seus
 * filhos ao topo da pilha. 
 * 
 * Exemplo de consulta:
 * ?- buscaSemRepeticaoDFS([(0,0)], [], Expansion).
 * 
 * @param Node nó atual da busca
 * @param Stack cauda da pilha, representa o pop(N) apos
 * sua verificacao.
 * @param Solution representa o caminho de uma possivel solucao
 * @param VisitedNodes precisa ser iniciado com [] na
 * consulta, essa lista funciona como cache de nos
 * visitados, sua verificacao evita a repeticoes de nos
 * */   
buscaSemRepeticaoDFS([Node|Stack], VisitedNodes, Solution):-
    append(VisitedNodes, [Node], UpdatedVisitedNodes),
    childrenDFS(Node, Children, UpdatedVisitedNodes, Stack),
    add_to_frontier_dfs(Children,Stack, Frontier),
    buscaSemRepeticaoDFS(Frontier, UpdatedVisitedNodes, Solution).

/* Usado para dar pop no Node atual, permitindo explorar
 * o caminho do proximo no em paralelo.
 * 
 * @param _ nó atual da busca
 * @param Stack cauda da pilha, representa o pop(N) apos
 * sua verificacao.
 * @param Solution representa o caminho de uma possivel solucao
 * @param VisitedNodes precisa ser iniciado com [] na
 * consulta, essa lista funciona como cache de nos
 * visitados, sua verificacao evita a repeticoes de nos
 * */
buscaSemRepeticaoDFS([_|Stack], VisitedNodes, Solution):- 
    buscaSemRepeticaoDFS(Stack, VisitedNodes, Solution).

/* Adiciona novos nodes a pilha de busca.
 * A adicao desses nodes ao topo da pilha
 * determina o metodo de Busca em Profundidade
 * 
 * @param NN novos nodes
 * @param Stack pilha que determina a ordem de expansao
 * @param UpdatedStack pilha retornada apos adicao
 * */
add_to_frontier_dfs(NN,Stack,UpdatedStack) :- 
    append(NN,Stack,UpdatedStack).

/* Retorna os filhos do nó atual
 * se difere do vizinhos por não incluir anscestrais
 * contornando existencia de ciclos na arvore
 * Se difere do children da BFS por precisar
 * inverter a ordem dos filhos a fim de empilhar
 * da esquerda para a direita, tornando o mais a 
 * direita o topo da pilha
 * 
 * @param CurrentNode nó atual da busca
 * @param Children lista retornada com os filhos 
 * @param VisitedNodes nós já visitados, lista usada para nao usarmos
 * nos ja visitados como parte dos filhos
 * @param Stack Stack, usada para nao retornarmos integrantes
 * da pilha como parte dos filhos
 * */
childrenDFS(CurrentNode, Children, VisitedNodes, Stack) :- 
    findall(FinalResults, acao(CurrentNode, _, FinalResults), Neighboors), 
    findall(X, (member(X,Neighboors), not(member(X,VisitedNodes)), not(member(X,Stack))), UnorderedChildren), %monta uma lista de filhos nao ordenados que nao estao em nos visitados e nem na pilha
    reverse(UnorderedChildren,Children).  %garante que a ordem dos filhos seja da direita para a esquerda, deixando o mais a direita na frente