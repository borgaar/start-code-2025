import 'package:equatable/equatable.dart';

class RecipeGroup extends Equatable {
  final String title;
  final List<String> items;
  const RecipeGroup(this.title, this.items);

  @override
  List<Object?> get props => [title, items];
}

abstract class AiAssistantState extends Equatable {
  const AiAssistantState();
  @override
  List<Object?> get props => [];
}

class AiAssistantInitial extends AiAssistantState {
  const AiAssistantInitial();
}

class AiAssistantLoading extends AiAssistantState {
  const AiAssistantLoading();
}

class AiAssistantSuccess extends AiAssistantState {
  final List<RecipeGroup> groups;
  const AiAssistantSuccess(this.groups);
  @override
  List<Object?> get props => [groups];
}

class AiAssistantFailure extends AiAssistantState {
  final String message;
  const AiAssistantFailure(this.message);
  @override
  List<Object?> get props => [message];
}
