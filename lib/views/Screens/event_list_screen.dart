import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/controllers/user_controller.dart';
import 'package:hedieaty/models/model/event.dart';
import 'package:hedieaty/views/Screens/create_or_update_event.dart';
import 'package:hedieaty/views/widgets/event_item.dart';
import 'package:hedieaty/views/widgets/event_sort_filter_functionality.dart';

class EventListScreen extends StatefulWidget {
  final String userId;
  const EventListScreen({super.key, required this.userId});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final EventSortFilterFunctionality _filterSorter =
      EventSortFilterFunctionality();
  List<Event>? events;
  List<Event>? filteredEvents;
  String? friendName;
  bool isCurrentUser = true;
  bool isLoading = true;

  String sortCriteria = 'Name';
  String? selectedCategoryFilter;
  String? selectedDateFilter;

  Future<void> _getEvents() async {
    final currentUser = await UserController.isCurrentUser(widget.userId);
    final List<Event> returnedEvents;
    // if not current user fetch from Fiestore
    if (!currentUser) {
      final fullName = await UserController.getUserFullName(widget.userId);
      friendName = fullName.split(' ')[0];
      isCurrentUser = false;
      returnedEvents = await EventController.getEventList(widget.userId, false);
    } else {
      // if current user fetch from local DB
      returnedEvents = await EventController.getEventList(widget.userId, true);
    }
    setState(() {
      events = returnedEvents;
      filteredEvents = List.from(events!);
      isLoading = false;
    });
  }

  void onUpdateEvent() async {
    _getEvents();
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event Updated successfully!')));
  }

  void onAddEvent(Event event) {
    setState(() {
      events!.add(event);
      filteredEvents = List.from(events!);
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')));
  }

  void onRemoveEvent(Event event) async {
    final updatedEvent = await EventController.retrieveEventById(eventId: event.localId!.toString());
    await EventController.deleteEvent(updatedEvent!.localId!, id: updatedEvent.id);
    setState(() {
      events!.remove(event);
      filteredEvents = List.from(events!);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event Deleted successfully!')));
  }

  void _applyFilters() {
    if (events == null) return;
    setState(() {
      filteredEvents = _filterSorter.applyFilters(
        events: events!,
        categoryFilter: selectedCategoryFilter,
        dateFilter: selectedDateFilter,
      );
      if (sortCriteria == 'Ascending') {
        filteredEvents = _filterSorter.sortByNameAscending(filteredEvents!);
      } else if (sortCriteria == 'Descending') {
        filteredEvents = _filterSorter.sortByNameDescending(filteredEvents!);
      }
    });
  }

  void filterByCategory(String? category) {
    setState(() {
      selectedCategoryFilter = category;
      _applyFilters();
    });
  }

  void filterByDate(String? dateFilter) {
    setState(() {
      selectedDateFilter = dateFilter;
      _applyFilters();
    });
  }

  @override
  void initState() {
    super.initState();
    _getEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: const Key('event_list'),
        appBar: AppBar(
          title: Text(isLoading
              ? 'Loading...'
              : isCurrentUser
                  ? 'My Events'
                  : '$friendName\'s Events'),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort_by_alpha_sharp, color: Colors.white),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                setState(() {
                  sortCriteria = value;
                  _applyFilters();
                });
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                    value: 'Ascending',
                    child: Row(
                      children: [
                        Text('Sort Ascending'),
                        Spacer(),
                        Icon(Icons.arrow_upward, color: Colors.green)
                      ],
                    )),
                PopupMenuItem(
                    value: 'Descending',
                    child: Row(
                      children: [
                        Text('Sort Descending'),
                        Spacer(),
                        Icon(Icons.arrow_downward, color: Colors.red)
                      ],
                    )),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Reset Filters and Sorting',
              onPressed: () {
                setState(() {
                  selectedCategoryFilter = null;
                  selectedDateFilter = null;
                  filteredEvents = List.from(events!);
                  sortCriteria = 'Name';
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                          hint: const Row(
                            children: [
                              Icon(Icons.category, color: Colors.purple),
                              SizedBox(width: 5),
                              Text('Category',
                                  style: TextStyle(color: Colors.black))
                            ],
                          ),
                          value: selectedCategoryFilter,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.purple),
                          borderRadius: BorderRadius.circular(12),
                          onChanged: filterByCategory,
                          items: Category.values
                              .map((category) => DropdownMenuItem(
                                  value: category.name,
                                  child: Text(category.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))))
                              .toList()),
                      const SizedBox(width: 20),
                      // Date Filter
                      DropdownButton<String>(
                        hint: const Row(
                          children: [
                            Icon(Icons.date_range, color: Colors.purple),
                            SizedBox(width: 5),
                            Text('Status',
                                style: TextStyle(color: Colors.black))
                          ],
                        ),
                        value: selectedDateFilter,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.purple),
                        borderRadius: BorderRadius.circular(12),
                        onChanged: filterByDate,
                        items: const [
                          DropdownMenuItem(
                              value: 'Past',
                              child: Text('Past',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DropdownMenuItem(
                              value: 'Current',
                              child: Text('Current',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DropdownMenuItem(
                              value: 'Upcoming',
                              child: Text('Upcoming',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: filteredEvents == null
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEvents!.isEmpty
                      ? const Center(child: Text('No Available Events'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: filteredEvents!.length,
                          itemBuilder: (context, index) {
                            return EventItem(
                              userId: widget.userId,
                              event: filteredEvents![index],
                              isCurrentUser: isCurrentUser,
                              onUpdateButtonPress: onUpdateEvent,
                              onRemoveButtonPress: onRemoveEvent,
                            );
                          },
                        ),
            ),
          ],
        ),
        floatingActionButton: isCurrentUser
            ? FloatingActionButton.extended(
                key: const Key('create_event'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Add Event'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) =>
                        CreateOrUpdateEvent(onAddEvent: onAddEvent),
                  ),
                ),
              )
            : null);
  }
}
