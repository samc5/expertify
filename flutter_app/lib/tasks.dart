import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String query = """
query fetchAllTodos {
  todos {
    success
    errors
    todos {
      name
      is_executed
      id
    }
  }
}
""";

const String markDone = """
mutation MarkDone(\$todoId: String!) {
  markDone(todoId: \$todoId) {
    success
    errors
    todo {
      id
      is_executed
      name
    }
  }
}
""";

const String deleteTodo = """
mutation deleteTodo(\$todoId: ID!){
  deleteTodo(todoId: \$todoId) {
    success
    errors
  }
}
""";

const String newTodo = """
mutation newTodo(\$name: String!) {
  createTodo(name: \$name) {
    success
    errors
    todo {
      id
      is_executed
      name
    }
  }
}
""";

final HttpLink httpLink = HttpLink("http://localhost:5000/graphql");

final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
  GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  ),
);

class TasksWidget extends StatefulWidget {
  const TasksWidget({Key? key}) : super(key: key);

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  TextEditingController newTaskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Query(
        options: QueryOptions(
            document: gql(query),
            variables: const <String, dynamic>{"variableName": "value"}),
        builder: (result, {fetchMore, refetch}) {
          if (result.hasException) {
            print(result.exception.toString());
            return const Center(
              child: Text("Error occurred while fetching data!"),
            );
          }
          if (result.data == null) {
            return const Center(
              child: Text("No data received!"),
            );
          }
          //print(result.data);
          final todos = result.data!["todos"];
          print(todos);
          print(todos.length);
          print(todos['todos']);
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: newTaskController,
                        decoration: InputDecoration(
                          labelText: 'New Task',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Mutation(
                        options: MutationOptions(document: gql(newTodo)),
                        builder: (runMutation, result) {
                          return ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.amberAccent),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.purple)),
                              child: Text("Add"),
                              onPressed: () async {
                                if (newTaskController.text.isEmpty) {
                                  return;
                                }
                                runMutation({
                                  'name': newTaskController.text,
                                });
                                newTaskController.clear();
                                await Future.delayed(
                                    const Duration(milliseconds: 30));
                                if (refetch != null) {
                                  refetch();
                                }
                              });
                        })
                  ],
                ),
                if (todos['todos'].isEmpty)
                  Center(
                    heightFactor: MediaQuery.of(context).size.height * 0.03,
                    child: const Text(
                      'You have no tasks.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ListView.builder(
                          itemCount: todos['todos'].length,
                          itemBuilder: (ctx, i) => Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: ListTile(
                                  tileColor: Colors.black12,
                                  leading: SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: Mutation(
                                        options: MutationOptions(
                                            document: gql(markDone)),
                                        builder: (runMutation, result) {
                                          return Checkbox(
                                              value: todos['todos'][i]
                                                  ['is_executed'],
                                              activeColor: Colors.purple,
                                              onChanged: (newValue) {
                                                runMutation({
                                                  'todoId': todos['todos'][i]
                                                      ['id']
                                                });
                                                print(todos['todos'][i]['id']);
                                              },
                                              tristate: false);
                                        },
                                      )),
                                  title: Text(todos['todos'][i]['name']),
                                  trailing: Mutation(
                                    options: MutationOptions(
                                        document: gql(deleteTodo)),
                                    builder: (runMutation, result) {
                                      return IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            runMutation({
                                              'todoId': todos['todos'][i]['id']
                                            });
                                            print(todos['todos'][i]['id']);
                                            await Future.delayed(const Duration(
                                                milliseconds: 45));
                                            if (refetch != null) {
                                              refetch();
                                            }
                                          });
                                    },
                                  ),
                                  onTap: () {},
                                ),
                              )),
                    ),
                  ),
              ],
            ),
          );
        });
  }
}
