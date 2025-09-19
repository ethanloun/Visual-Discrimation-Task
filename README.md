# Visual Discrimination Task

A comprehensive psychophysics experiment application designed to study human visual discrimination by analyzing participants' ability to recognize rotated figures. Built with SwiftUI for macOS, this application provides a complete framework for conducting cognitive psychology and human-computer interaction (HCI) experiments.

## Features

### 🧠 Experiment Design
- **Configurable Parameters**: Customizable trial counts, rotation angles, figure types, and timing
- **Balanced Design**: Automatically generates balanced trials across all conditions
- **Randomization**: Shuffled trial presentation to minimize order effects
- **Break Management**: Automatic breaks at configurable intervals

### 📊 Data Collection & Analysis
- **Real-time Data Collection**: Tracks responses, reaction times, and accuracy
- **Statistical Analysis**: Comprehensive statistical analysis including:
  - Basic descriptive statistics
  - Rotation angle analysis
  - Figure type comparison
  - Learning curve analysis
  - Correlation analysis
  - T-test comparisons

### 📈 Visualization & Results
- **Interactive Charts**: Visual representation of results using SwiftUI Charts
- **Multiple Export Formats**: JSON, CSV, and text export options
- **Detailed Results Table**: Complete trial-by-trial data view
- **Summary Statistics**: Key performance metrics at a glance

### 🎨 Visual Stimuli
- **Two Figure Types**: Simple and complex geometric figures
- **Rotation Capabilities**: 0° to 180° rotation in configurable increments
- **Consistent Presentation**: Standardized visual presentation across trials

## Architecture

### Core Components

#### Models
- **`ExperimentModels.swift`**: Core data structures and experiment session management
- **`StatisticalAnalysis.swift`**: Statistical analysis engine with various analytical methods

#### Views
- **`ExperimentView.swift`**: Main experiment interface and flow control
- **`FigureGenerator.swift`**: Visual stimulus generation and rendering
- **`ConfigurationView.swift`**: Experiment parameter configuration
- **`ResultsView.swift`**: Results visualization and analysis display
- **`ExportView.swift`**: Data export functionality

### Key Features

#### Experiment Session Management
```swift
class ExperimentSession: ObservableObject {
    @Published var config: ExperimentConfig
    @Published var trials: [TrialData] = []
    @Published var currentTrial: TrialData?
    // ... session management methods
}
```

#### Statistical Analysis Engine
```swift
class StatisticalAnalysis {
    static func calculateBasicStatistics(for trials: [TrialData]) -> BasicStatistics
    static func analyzeByRotationAngle(for trials: [TrialData]) -> [RotationAnalysis]
    static func analyzeByFigureType(for trials: [TrialData]) -> [FigureTypeAnalysis]
    // ... additional analysis methods
}
```

## Usage

### Running the Experiment

1. **Launch the Application**: Open the Visual Discrimination Task app
2. **Configure Parameters**: Click "Settings" to adjust experiment parameters
3. **Start Experiment**: Click "Start Experiment" to begin
4. **Participant Response**: Observe figures and respond with "Simple" or "Complex"
5. **View Results**: Review results and export data when complete

### Configuration Options

- **Participant ID**: Unique identifier for the participant
- **Total Trials**: Number of trials (20-200)
- **Presentation Duration**: How long each figure is shown (0.5-5.0 seconds)
- **Response Timeout**: Maximum time for response (1.0-10.0 seconds)
- **Break Interval**: Trials between breaks (10-50)
- **Figure Types**: Select which figure types to include
- **Rotation Angles**: Customize rotation angle range

### Data Export

The application supports multiple export formats:

- **JSON**: Complete structured data export
- **CSV**: Spreadsheet-compatible format
- **Text**: Human-readable summary report

## Technical Implementation

### Technologies Used
- **SwiftUI**: Modern declarative UI framework
- **macOS 15.5+**: Target platform with native performance
- **Charts Framework**: Data visualization (macOS 14.0+)
- **Core Data**: Local data persistence
- **UniformTypeIdentifiers**: File export functionality

### Performance Considerations
- **Efficient Rendering**: Optimized figure generation and rotation
- **Memory Management**: Proper cleanup of trial data
- **Real-time Statistics**: Live calculation of performance metrics
- **Smooth Animations**: 60fps figure rotation and transitions

## Research Applications

### Cognitive Psychology
- **Visual Recognition Studies**: Understanding how rotation affects object recognition
- **Attention Research**: Studying visual attention and processing
- **Learning Studies**: Analyzing learning curves and adaptation

### Human-Computer Interaction
- **Interface Design**: Testing visual design principles
- **Usability Studies**: Evaluating visual complexity effects
- **Accessibility Research**: Understanding visual processing differences

### Machine Learning
- **Cognitive Modeling**: Training models on human visual processing data
- **Computer Vision**: Comparing human and machine visual recognition
- **Data Collection**: Gathering labeled datasets for ML training

## Future Enhancements

### Planned Features
- **Additional Figure Types**: More complex visual stimuli
- **Eye Tracking Integration**: Gaze pattern analysis
- **Network Synchronization**: Multi-device data collection
- **Advanced Statistics**: More sophisticated statistical tests
- **Custom Stimuli**: User-defined figure generation

### Research Extensions
- **Cross-Cultural Studies**: International participant support
- **Longitudinal Studies**: Multi-session tracking
- **Clinical Applications**: Diagnostic tool development
- **Educational Use**: Student research projects

## Contributing

This project is designed as a research tool and educational resource. Contributions are welcome in the following areas:

- **Statistical Methods**: Additional analysis techniques
- **Visual Stimuli**: New figure types and complexity levels
- **User Interface**: Improved participant experience
- **Data Analysis**: Enhanced visualization and reporting
- **Documentation**: Research methodology and best practices

## License

This project is intended for educational and research purposes. Please ensure compliance with your institution's research ethics guidelines when conducting experiments with human participants.

## Contact

For questions about the implementation or research applications, please refer to the project documentation or contact the development team.

---

**Note**: This application is designed for research purposes and should be used in accordance with appropriate ethical guidelines for human subjects research.
