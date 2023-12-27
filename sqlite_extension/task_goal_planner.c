#include <sqlite3ext.h>
SQLITE_EXTENSION_INIT1

typedef struct {
  // How much information to print while the program is running
  int verbose; // default: 0

  // Sequence number to use when making copies of states.
  int _next_state_number; // default: 0

  // Sequence number to use when making copies of multigoals.
  int _next_multigoal_number; // default: 0

  // There is currently no description for this property.
  Object current_domain; // default: null

  // Sequence number to use when making copies of domains.
  int _next_domain_number; // default: 0

  // A list of all domains that have been created
  Resource *_domains; // default: <unknown>

  // If verify_goals is True, then whenever the planner uses a method m to
  // refine a unigoal or multigoal, it will insert a "verification" task into
  // the current partial plan. If verify_goals is False, the planner won't
  // insert any verification tasks into the plan.
  bool verify_goals; // default: true
} Planner;

// Now let's define the stubs for your methods

void apply_action_and_continue(Planner *planner, Dictionary state, Array task1,
                               Array todo_list, Array plan, int depth) {
  // Your code here
}

void refine_multigoal_and_continue(Planner *planner, Dictionary state,
                                   Multigoal goal1, Array todo_list, Array plan,
                                   int depth) {
  // Your code here
}

void refine_task_and_continue(Planner *planner, Variant state, Variant task1,
                              Variant todo_list, Variant plan, Variant depth) {
  // Your code here
}

void refine_unigoal_and_continue(Planner *planner, Dictionary state,
                                 Array goal1, Array todo_list, Array plan,
                                 int depth) {
  // Your code here
}

void declare_actions(Planner *planner, Variant actions) {
  // Your code here
}

void declare_multigoal_methods(Planner *planner, Array methods) {
  // Your code here
}

void declare_task_methods(Planner *planner, StringName task_name,
                          Array methods) {
  // Your code here
}

void declare_unigoal_methods(Planner *planner, StringName state_var_name,
                             Array methods) {
  // Your code here
}

void find_plan(Planner *planner, Dictionary state, Array todo_list) {
  // Your code here
}

void m_split_multigoal(Planner *planner, Dictionary state,
                       Multigoal multigoal) {
  // Your code here
}

void print_actions(Planner *planner, Object domain) {
  // Your code here
}

void print_domain(Planner *planner, Object domain) {
  // Your code here
}

void print_methods(Planner *planner, Object domain) {
  // Your code here
}

void print_simple_temporal_network(Planner *planner, Object domain) {
  // Your code here
}

Dictionary run_lazy_lookahead(Planner *planner, Dictionary state,
                              Array todo_list, int max_tries) {
  // Your code here
}

void seek_plan(Planner *planner, Dictionary state, Array todo_list, Array plan,
               int depth) {
  // Your code here
}

#ifdef _WIN32
__declspec(dllexport)
#endif
    int sqlite3_extension_init(sqlite3 *db, char **pzErrMsg,
                               const sqlite3_api_routines *pApi) {
  SQLITE_EXTENSION_INIT2(pApi)
  // Register your SQL functions here
  return 0;
}
