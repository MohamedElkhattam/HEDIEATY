import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/models/model/event.dart';
import 'package:hedieaty/views/Screens/gift_details_screen.dart';

class CreateOrUpdateEvent extends StatefulWidget {
  const CreateOrUpdateEvent({
    super.key,
    this.event,
    this.onUpdateEvent,
    this.onAddEvent,
  });
  final Event? event;
  final void Function(Event event)? onAddEvent;
  final void Function()? onUpdateEvent;

  @override
  State<CreateOrUpdateEvent> createState() => _CreateOrUpdateEventState();
}

class _CreateOrUpdateEventState extends State<CreateOrUpdateEvent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Category _selectedCategory = Category.holiday;
  DateTime? _selectedDate;
  String? _selectedDateAsString;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _nameController.text = widget.event!.name;
      _locationController.text = widget.event!.location;
      _descriptionController.text = widget.event!.description;
      _selectedDate = widget.event!.date;
      _selectedCategory = widget.event!.category;
      _selectedDateAsString =
          '${widget.event!.date.year} / ${widget.event!.date.month} / ${widget.event!.date.day}';
    }
  }

  void _datePickerSheet() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );
    setState(() {
      _selectedDateAsString =
          '${pickedDate!.year} / ${pickedDate.month} / ${pickedDate.day}';
      _selectedDate = pickedDate;
    });
  }

  void _createxUpdateEvent() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      try {
        if (widget.onUpdateEvent != null && widget.event != null) {
          await EventController.updateExistingEvent(
            _nameController.text,
            _descriptionController.text,
            _locationController.text,
            _selectedDate!,
            _selectedCategory,
            widget.event!.localId!,
          );
          widget.onUpdateEvent!();
          if (!mounted) return;
          Navigator.pop(context);
        } else if (widget.event == null) {
          final receivedEvent = await EventController.saveNewEvent(
            _nameController.text,
            _descriptionController.text,
            _locationController.text,
            _selectedDate!,
            _selectedCategory,
          );
          if (!mounted) return;
          if (widget.onAddEvent != null) {
            widget.onAddEvent!(receivedEvent!);
            Navigator.pop(context);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => GiftDetailsScreen(
                  eventLocalId: receivedEvent!.localId!,
                  isCurrentUser: true,
                  isEventValid: receivedEvent.date.isAfter(DateTime.now()),
                ),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to create Event!')));
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date for the event.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('create_or_update_event'),
      appBar: AppBar(
        title: Text(widget.event == null ? 'Create Event' : 'Update Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  key: const Key('name'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Event Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the event name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('location'),
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('description'),
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the description';
                    }
                    return null;
                  },
                ),
                Center(
                  child: DropdownButton<Category>(
                    key: const Key('categoryDropdown'),
                    alignment: Alignment.center,
                    borderRadius: BorderRadius.circular(5),
                    items: Category.values
                        .map((e) => DropdownMenuItem<Category>(
                              alignment: Alignment.center,
                              value: e,
                              child: Text(e.name.toUpperCase()),
                            ))
                        .toList(),
                    value: _selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : 'Selected Date: $_selectedDateAsString',
                      key: const Key('selectedDateText'),
                    ),
                    Container(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: IconButton(
                        key: const Key('datePickerButton'),
                        onPressed: _datePickerSheet,
                        icon: const Icon(Icons.calendar_month),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    key: const Key('create_event'),
                    onPressed: _createxUpdateEvent,
                    child: Text(
                        widget.event == null ? 'Create Event' : 'Update Event'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
