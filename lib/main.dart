import 'package:flutter/material.dart';

void main() {
  runApp(const CinemaCommunityApp());
}

enum MovieRating { livre, dez, doze, quatorze, dezesseis, dezoito }

enum RoomType { azul, verde, vermelha, externa }

extension MovieRatingLabel on MovieRating {
  String get label => switch (this) {
        MovieRating.livre => 'Livre',
        MovieRating.dez => '10',
        MovieRating.doze => '12',
        MovieRating.quatorze => '14',
        MovieRating.dezesseis => '16',
        MovieRating.dezoito => '18',
      };
}

extension RoomTypeLabel on RoomType {
  String get label => switch (this) {
        RoomType.azul => 'Sala Azul',
        RoomType.verde => 'Sala Verde',
        RoomType.vermelha => 'Sala Vermelha',
        RoomType.externa => 'Área Externa',
      };
}

class CinemaSession {
  CinemaSession({
    required this.id,
    required this.title,
    required this.rating,
    required this.room,
    required this.seats,
    required this.hasDebate,
  });

  int id;
  String title;
  MovieRating rating;
  RoomType room;
  int seats;
  bool hasDebate;
}

class CinemaCommunityApp extends StatelessWidget {
  const CinemaCommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sessões de Cinema Comunitário',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F2937)),
        useMaterial3: true,
      ),
      home: const CinemaHomePage(),
    );
  }
}

class CinemaHomePage extends StatefulWidget {
  const CinemaHomePage({super.key});

  @override
  State<CinemaHomePage> createState() => _CinemaHomePageState();
}

class _CinemaHomePageState extends State<CinemaHomePage> {
  final TextEditingController _searchController = TextEditingController();

  final List<CinemaSession> _sessions = [
    CinemaSession(
      id: 1,
      title: 'No Ritmo do Coração',
      rating: MovieRating.dez,
      room: RoomType.azul,
      seats: 42,
      hasDebate: true,
    ),
    CinemaSession(
      id: 2,
      title: 'A Viagem de Chihiro',
      rating: MovieRating.livre,
      room: RoomType.verde,
      seats: 30,
      hasDebate: false,
    ),
  ];

  String _search = '';
  MovieRating? _ratingFilter;
  RoomType? _roomFilter;
  bool? _debateFilter;
  int _nextId = 3;

  List<CinemaSession> get _filteredSessions {
    return _sessions.where((session) {
      final matchesSearch = session.title.toLowerCase().contains(_search.toLowerCase());
      final matchesRating = _ratingFilter == null || session.rating == _ratingFilter;
      final matchesRoom = _roomFilter == null || session.room == _roomFilter;
      final matchesDebate = _debateFilter == null || session.hasDebate == _debateFilter;

      return matchesSearch && matchesRating && matchesRoom && matchesDebate;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openSessionForm({CinemaSession? session}) async {
    final result = await showDialog<CinemaSession>(
      context: context,
      builder: (context) => SessionFormDialog(session: session),
    );

    if (result == null) return;

    setState(() {
      if (session == null) {
        result.id = _nextId++;
        _sessions.add(result);
      } else {
        session.title = result.title;
        session.rating = result.rating;
        session.room = result.room;
        session.seats = result.seats;
        session.hasDebate = result.hasDebate;
      }
    });
  }

  void _deleteSession(CinemaSession session) {
    setState(() {
      _sessions.remove(session);
    });
  }

  void _resetFilters() {
    setState(() {
      _search = '';
      _ratingFilter = null;
      _roomFilter = null;
      _debateFilter = null;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _filteredSessions;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sessões de Cinema Comunitário',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gerencie sessões com busca, filtros e formulário validado.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Buscar por título',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onChanged: (value) => setState(() => _search = value),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          DropdownButtonFormField<MovieRating?>(
                            initialValue: _ratingFilter,
                            decoration: _fieldDecoration('Filtro de classificação'),
                            items: [
                              const DropdownMenuItem<MovieRating?>(
                                value: null,
                                child: Text('Todas'),
                              ),
                              ...MovieRating.values.map(
                                (rating) => DropdownMenuItem<MovieRating?>(
                                  value: rating,
                                  child: Text(rating.label),
                                ),
                              ),
                            ],
                            onChanged: (value) => setState(() => _ratingFilter = value),
                          ),
                          DropdownButtonFormField<RoomType?>(
                            initialValue: _roomFilter,
                            decoration: _fieldDecoration('Filtro de sala'),
                            items: [
                              const DropdownMenuItem<RoomType?>(
                                value: null,
                                child: Text('Todas'),
                              ),
                              ...RoomType.values.map(
                                (room) => DropdownMenuItem<RoomType?>(
                                  value: room,
                                  child: Text(room.label),
                                ),
                              ),
                            ],
                            onChanged: (value) => setState(() => _roomFilter = value),
                          ),
                          DropdownButtonFormField<bool?>(
                            initialValue: _debateFilter,
                            decoration: _fieldDecoration('Filtro de debate'),
                            items: const [
                              DropdownMenuItem<bool?>(value: null, child: Text('Todos')),
                              DropdownMenuItem<bool?>(value: true, child: Text('Com debate')),
                              DropdownMenuItem<bool?>(value: false, child: Text('Sem debate')),
                            ],
                            onChanged: (value) => setState(() => _debateFilter = value),
                          ),
                          TextButton.icon(
                            onPressed: _resetFilters,
                            icon: const Icon(Icons.filter_alt_off),
                            label: const Text('Limpar filtros'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Resultados',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          FilledButton.icon(
                            onPressed: () => _openSessionForm(),
                            icon: const Icon(Icons.add),
                            label: const Text('Nova sessão'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (sessions.isEmpty)
                        _EmptyState(
                          onCreate: () => _openSessionForm(),
                        )
                      else
                        ...sessions.map(
                          (session) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _SessionCard(
                              session: session,
                              onEdit: () => _openSessionForm(session: session),
                              onDelete: () => _deleteSession(session),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class SessionFormDialog extends StatefulWidget {
  const SessionFormDialog({super.key, this.session});

  final CinemaSession? session;

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _seatsController;
  late MovieRating? _rating;
  late RoomType? _room;
  late bool _hasDebate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.session?.title ?? '');
    _seatsController = TextEditingController(text: widget.session?.seats.toString() ?? '');
    _rating = widget.session?.rating;
    _room = widget.session?.room;
    _hasDebate = widget.session?.hasDebate ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_rating == null || _room == null) return;

    Navigator.of(context).pop(
      CinemaSession(
        id: widget.session?.id ?? 0,
        title: _titleController.text.trim(),
        rating: _rating!,
        room: _room!,
        seats: int.parse(_seatsController.text.trim()),
        hasDebate: _hasDebate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.session == null ? 'Nova sessão' : 'Editar sessão'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título do filme'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o título.';
                    }
                    if (value.trim().length < 3) {
                      return 'O título deve ter pelo menos 3 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<MovieRating>(
                  initialValue: _rating,
                  decoration: const InputDecoration(labelText: 'Classificação indicativa'),
                  items: MovieRating.values
                      .map(
                        (rating) => DropdownMenuItem<MovieRating>(
                          value: rating,
                          child: Text(rating.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _rating = value),
                  validator: (value) => value == null ? 'Selecione a classificação.' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<RoomType>(
                  initialValue: _room,
                  decoration: const InputDecoration(labelText: 'Sala de exibição'),
                  items: RoomType.values
                      .map(
                        (room) => DropdownMenuItem<RoomType>(
                          value: room,
                          child: Text(room.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _room = value),
                  validator: (value) => value == null ? 'Selecione a sala.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _seatsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantidade de lugares'),
                  validator: (value) {
                    final seats = int.tryParse(value ?? '');
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a quantidade de lugares.';
                    }
                    if (seats == null || seats <= 0) {
                      return 'Use um número maior que zero.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Haverá debate após a sessão?'),
                  value: _hasDebate,
                  onChanged: (value) => setState(() => _hasDebate = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.session == null ? 'Criar' : 'Salvar'),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.onEdit,
    required this.onDelete,
  });

  final CinemaSession session;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Classificação ${session.rating.label} • ${session.room.label}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Excluir')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InfoChip(icon: Icons.event_seat, label: '${session.seats} lugares'),
                _InfoChip(
                  icon: session.hasDebate ? Icons.forum : Icons.forum_outlined,
                  label: session.hasDebate ? 'Com debate' : 'Sem debate',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.movie_filter_outlined, size: 56),
          const SizedBox(height: 12),
          Text(
            'Nenhuma sessão encontrada',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tente ajustar a busca ou os filtros, ou crie uma nova sessão.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Criar sessão'),
          ),
        ],
      ),
    );
  }
}
