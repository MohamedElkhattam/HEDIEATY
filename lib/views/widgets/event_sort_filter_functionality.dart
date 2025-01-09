import 'package:hedieaty/models/model/event.dart';

class EventSortFilterFunctionality {
  final DateTime now = DateTime.now();

  List<Event> sortByNameAscending(List<Event> events) {
    events.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return events;
  }

  List<Event> sortByNameDescending(List<Event> events) {
    events.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    return events;
  }

  List<Event> applyFilters({
    required List<Event> events,
    String? categoryFilter,
    String? dateFilter,
  }) {
    return events.where((event) {
      bool matchesCategory = categoryFilter == null ||
          event.category.name.toLowerCase() == categoryFilter.toLowerCase();

      bool matchesDate = true;
      if (dateFilter != null) {
        final nowDate = DateTime(now.year, now.month, now.day);
        if (dateFilter == 'Past') {
          matchesDate = event.date.isBefore(nowDate);
        } else if (dateFilter == 'Current') {
          matchesDate = event.date.year == nowDate.year &&
              event.date.month == nowDate.month &&
              event.date.day == nowDate.day;
        } else if (dateFilter == 'Upcoming') {
          matchesDate = event.date.isAfter(nowDate);
        }
      }
      return matchesCategory && matchesDate;
    }).toList();
  }
}
