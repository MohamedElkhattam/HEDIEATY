import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'package:hedieaty/controllers/user_controller.dart';
import 'package:hedieaty/models/model/gift.dart';
import 'package:hedieaty/views/Screens/gift_details_screen.dart';
import 'package:hedieaty/views/widgets/gift_item.dart';
import 'package:hedieaty/views/widgets/gift_sort_filter_functionality.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class GiftListScreen extends StatefulWidget {
  const GiftListScreen({
    super.key,
    this.eventId,
    this.eventLocalId,
    required this.userId,
    required this.isCurrentUser,
  });
  final int? eventLocalId;
  final String? eventId;
  final String userId;
  final bool isCurrentUser;

  @override
  State<GiftListScreen> createState() => _GiftListScreenState();
}

class _GiftListScreenState extends State<GiftListScreen> {
  final GiftSortFilterFunctionality _filterSorter =
      GiftSortFilterFunctionality();
  List<Gift>? giftsList;
  List<Gift>? filteredGifts;
  String? friendName;
  String? fullName;
  bool isLoading = true;

  String sortCriteria = 'Ascending';
  String? selectedCategoryFilter;
  Status? selectedStatusFilter;

  void _getGifts() async {
    List<Gift>? returnedGifts;
    if (!widget.isCurrentUser) {
      fullName = await UserController.getUserFullName(widget.userId);
      friendName = fullName!.split(' ')[0];
      returnedGifts = await GiftController.getGiftList(widget.eventId!, false);
    } else {
      returnedGifts = await GiftController.getGiftList(
          widget.eventLocalId.toString(), true);
    }
    setState(() {
      giftsList = returnedGifts;
      filteredGifts = List.from(returnedGifts!);
      isLoading = false;
    });
  }

  void onChangeStatus(Gift gift) async {
    try {
      final result = await GiftController.managePledgingGifts(gift);
      _getGifts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gift $result')));
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(error.toString(), style: const TextStyle(fontSize: 15))));
    }
  }

  void onUpdateGift() async {
    _getGifts();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift Updated successfully!')));
  }

  void onAddGift(Gift gift) {
    setState(() {
      giftsList!.add(gift);
      filteredGifts = List.from(giftsList!);
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift created successfully!')));
  }

  void onRemoveGift(Gift gift) async {
    final updatedGift =
        await GiftController.getUpdatedGiftLocally(gift.localId!);
    await GiftController.deleteGift(gift.localId!, giftId: updatedGift.id);

    setState(() {
      giftsList!.remove(gift);
      filteredGifts = List.from(giftsList!);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gift Deleted successfully!')));
  }

  void _applyFilters() {
    if (giftsList == null) return;

    setState(() {
      filteredGifts = _filterSorter.applyFilters(
        gifts: giftsList!,
        categoryFilter: selectedCategoryFilter,
        statusFilter: selectedStatusFilter,
      );

      if (sortCriteria == 'Name Ascending') {
        filteredGifts = _filterSorter.sortAscending(filteredGifts!, 'Name');
      } else if (sortCriteria == 'Name Descending') {
        filteredGifts = _filterSorter.sortDescending(filteredGifts!, 'Name');
      } else if (sortCriteria == 'Category Ascending') {
        filteredGifts = _filterSorter.sortAscending(filteredGifts!, 'Category');
      } else if (sortCriteria == 'Category Descending') {
        filteredGifts =
            _filterSorter.sortDescending(filteredGifts!, 'Category');
      }
    });
  }

  void filterByStatus(Status? status) {
    setState(() {
      selectedStatusFilter = status;
      _applyFilters();
    });
  }

  void resetFiltersAndSorting() {
    setState(() {
      selectedCategoryFilter = null;
      selectedStatusFilter = null;
      sortCriteria = 'Ascending';
      filteredGifts = List.from(giftsList!);
    });
  }

  @override
  void initState() {
    super.initState();
    _getGifts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('gift_list'),
      appBar: AppBar(
        title: Text(isLoading
            ? 'Loading...'
            : widget.isCurrentUser
                ? 'MY GIFT LIST'
                : '$friendName\'s GIFTS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Reset Filters and Sorting',
            onPressed: resetFiltersAndSorting,
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
                    DropdownButton<Status>(
                      value: selectedStatusFilter,
                      underline: const SizedBox(),
                      hint: const Text('Filter by Status'),
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.purple),
                      borderRadius: BorderRadius.circular(12),
                      onChanged: filterByStatus,
                      items: Status.values
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ))
                          .toList(),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort_by_alpha_sharp,
                          color: Colors.black),
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
                            value: 'Name Ascending',
                            child: Row(children: [
                              Text('Sort By Name Ascending'),
                              Spacer(),
                              Icon(Icons.arrow_upward, color: Colors.green)
                            ])),
                        PopupMenuItem(
                            value: 'Name Descending',
                            child: Row(children: [
                              Text('Sort By Name Descending'),
                              Spacer(),
                              Icon(Icons.arrow_downward, color: Colors.red)
                            ])),
                        PopupMenuItem(
                            value: 'Category Ascending',
                            child: Row(children: [
                              Text('Sort By Category Ascending'),
                              Spacer(),
                              Icon(Icons.arrow_upward, color: Colors.green)
                            ])),
                        PopupMenuItem(
                            value: 'Category Descending',
                            child: Row(children: [
                              Text('Sort By Category Descending'),
                              Spacer(),
                              Icon(Icons.arrow_downward, color: Colors.red)
                            ])),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredGifts == null
                ? const Center(child: CircularProgressIndicator())
                : filteredGifts!.isEmpty
                    ? const Center(child: Text('No Available Gifts'))
                    : ListView.builder(
                        itemCount: filteredGifts!.length,
                        itemBuilder: (context, index) {
                          return GiftItem(
                            gift: filteredGifts![index],
                            eventFireStoreId: widget.eventId,
                            eventLocalId: widget.eventLocalId,
                            isCurrentUser: widget.isCurrentUser,
                            onChangeStatus: onChangeStatus,
                            onRemoveButtonPress: onRemoveGift,
                            onUpdateGift: onUpdateGift,
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: widget.isCurrentUser
          ? SpeedDial(
              key: const Key('choose_operation'),
              icon: Icons.add,
              activeIcon: Icons.close,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              children: [
                  SpeedDialChild(
                      key: const Key('add_gift'),
                      child: const Icon(Icons.event_available),
                      label: 'Add Gift',
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      onTap: () async {
                        final receivedEvent =
                            await EventController.retrieveEventById(
                                eventId: widget.eventLocalId.toString());
                        if (receivedEvent == null) return;
                        if (!context.mounted) return;
                        final DateTime now = DateTime.now();
                        final nowDate = DateTime(now.year, now.month, now.day);
                        final isEventDateValid =
                            !receivedEvent.date.isBefore(nowDate);
                        if (isEventDateValid) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GiftDetailsScreen(
                                eventLocalId: widget.eventLocalId!,
                                isCurrentUser: widget.isCurrentUser,
                                onAddClick: onAddGift,
                                isEventValid: isEventDateValid,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Can\'t Create Gifts for past Events',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          );
                        }
                      }),
                  SpeedDialChild(
                    child: const Icon(Icons.published_with_changes),
                    label: 'Publish Online',
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    onTap: () async {
                      await GiftController.publishGiftList(
                          widget.eventLocalId!);
                    },
                  ),
                ])
          : null,
    );
  }
}
